-- multis.lua
local multis = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")
local templates = require("templates")

local function create_instrument_for_label(base_instrument, label)
    local song = renoise.song()
    local current_index = song.selected_instrument_index
    local new_instrument = duplicator.duplicate_instrument(string.format("%s Multi-Sample Rolls", label), 0)
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function invert_pattern_string(pattern_str)
    local sections = {}
    for section in pattern_str:gmatch("[^|]+") do
        local reversed = string.reverse(section)
        table.insert(sections, reversed)
    end
    return table.concat(sections, "|")
end

local function create_inverted_pattern(pattern)
    local inverted = {}
    for k, v in pairs(pattern) do
        if k == "steps" then
            inverted[k] = v  
        else
            inverted[k] = invert_pattern_string(v)
        end
    end
    return inverted
end

local function parse_pattern_string(pattern_str)
    local lines = {}
    local current_line = 1
    for section in pattern_str:gmatch("[^|]+") do
        for i = 1, #section do
            lines[current_line] = section:sub(i, i)
            current_line = current_line + 1
        end
    end
    return lines
end

local function get_multi_roll_slices(saved_labels, label)
    local slices = {roll = {}, ghost = {}}
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == label then
            local index = tonumber(hex_key, 16) - 1
            if label_data.roll then
                table.insert(slices.roll, index)
            elseif label_data.ghost_note then
                table.insert(slices.ghost, index)
            end
        end
    end
    return slices
end

local function create_slice_variations(roll_slices, ghost_slices)
    local variations = {}
    if #roll_slices >= 2 and #ghost_slices >= 2 then
        table.insert(variations, {roll1 = roll_slices[1], roll2 = roll_slices[2], ghost1 = ghost_slices[1], ghost2 = ghost_slices[2]})
    end
    return variations
end

local function apply_multi_pattern(phrase, pattern_table, slice_set, steps)
    local parsed_patterns = {}
    for pattern_type, pattern_str in pairs(pattern_table) do
        if pattern_type ~= "steps" then
            parsed_patterns[pattern_type] = parse_pattern_string(pattern_str)
        end
    end
    
    for source_line = 1, steps do
        local target_line = (source_line - 1) * 4 + 1
        local note_column = phrase:line(target_line):note_column(1)
        note_column:clear()
        
        if parsed_patterns["R"] and parsed_patterns["R"][source_line] == "R" then
            note_column.note_value = 48
            note_column.instrument_value = slice_set.roll1
        elseif parsed_patterns["L"] and parsed_patterns["L"][source_line] == "L" then
            note_column.note_value = 48
            note_column.instrument_value = slice_set.roll2
        elseif parsed_patterns["G"] and parsed_patterns["G"][source_line] == "G" then
            note_column.note_value = 48
            note_column.instrument_value = slice_set.ghost1
        elseif parsed_patterns["H"] and parsed_patterns["H"][source_line] == "H" then
            note_column.note_value = 48
            note_column.instrument_value = slice_set.ghost2
        end
        
        if parsed_patterns["V"] then
            local vol_char = parsed_patterns["V"][source_line]
            if vol_char and vol_char:match("%d") then
                note_column.volume_value = tonumber(vol_char .. "0", 16)
            end
        end
        
        if target_line + 1 <= phrase.number_of_lines then
            phrase:line(target_line + 1):note_column(1):clear()
        end
    end
end

local function create_timing_variation(instrument, base_phrase, division)
    local new_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    new_phrase:copy_from(base_phrase)
    new_phrase.name = string.format("%s 1/%d", base_phrase.name, division)
    new_phrase.lpb = math.ceil(base_phrase.lpb * (division / 8))
    return new_phrase
end

function multis.create_multi_patterns(instrument, original_phrase, saved_labels)
    local all_phrases = {}
    local instruments_created = {}
    
    local label_slices = {}
    for _, label_data in pairs(saved_labels) do
        local label = label_data.label
        if not label_slices[label] then
            label_slices[label] = get_multi_roll_slices(saved_labels, label)
        end
    end
    
    for name, pattern in pairs(templates) do
        if string.find(name, "_m_") then
            local steps = pattern.steps or 16
            
            local patterns_to_process = {
                {pattern = pattern, name_prefix = ""},
                {pattern = create_inverted_pattern(pattern), name_prefix = "Inverted "}
            }
            
            for label, slices in pairs(label_slices) do
                if #slices.roll >= 2 and #slices.ghost >= 2 then
                    local label_instrument = instruments_created[label]
                    if not label_instrument then
                        label_instrument = create_instrument_for_label(instrument, label)
                        instruments_created[label] = label_instrument
                    end
                    
                    local variations = create_slice_variations(slices.roll, slices.ghost)
                    
                    for _, pattern_variant in ipairs(patterns_to_process) do
                        for var_idx, slice_set in ipairs(variations) do
                            local base_phrase = label_instrument:insert_phrase_at(#label_instrument.phrases + 1)
                            base_phrase:copy_from(original_phrase)
                            base_phrase.number_of_lines = steps * 4
                            base_phrase.name = string.format("%s%s %s Var %d", 
                                pattern_variant.name_prefix, 
                                name, 
                                label, 
                                var_idx)
                            utils.clear_phrase(base_phrase)
                            
                            apply_multi_pattern(base_phrase, pattern_variant.pattern, slice_set, steps)
                            utils.humanize_phrase(base_phrase)
                            utils.apply_decay_compensation(base_phrase)
                            table.insert(all_phrases, base_phrase)
                            
                            for _, division in ipairs({4, 6, 12, 16}) do
                                local variation = create_timing_variation(label_instrument, base_phrase, division)
                                utils.humanize_phrase(variation)
                                utils.apply_decay_compensation(variation)
                                table.insert(all_phrases, variation)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return all_phrases, instruments_created
end

function multis.show_results(new_phrases, created_instruments)
    local info = "Created Multi-Roll Patterns:\n\n"
    
    if created_instruments then
        info = info .. "Created Instruments:\n"
        for label, instrument in pairs(created_instruments) do
            info = info .. string.format("- %s (%d patterns)\n", 
                instrument.name, 
                #instrument.phrases)
        end
        info = info .. "\n"
    end
    
    info = info .. "Pattern Details:\n"
    for i, phrase in ipairs(new_phrases) do
        info = info .. string.format("Phrase %d: %s\n", i, phrase.name)
        info = info .. string.format("  Lines: %d, LPB: %d\n\n", 
            phrase.number_of_lines, phrase.lpb)
    end
    
    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Multi-Roll Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
    renoise.app():show_custom_dialog("Multi-Roll Pattern Results", dialog_content)
end

return multis