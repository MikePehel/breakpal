-- beats.lua
local beats = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")
local templates = require("templates")

local function create_instrument_for_flag(base_instrument, flag)
    local song = renoise.song()
    local flag_names = {
        l = "Latin",
        u = "Afro Cuban",
        a = "Afrobeat",
        j = "Jazz",
        f = "Funk"
    }
    
    local name = string.format("%s Beat Patterns", flag_names[flag] or "Generic")
    local new_instrument = duplicator.duplicate_instrument(name, 0)
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function get_kick_slice(saved_labels)
    local roll_kick = nil
    local regular_kick = nil
    
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == "Kick" then
            local index = tonumber(hex_key, 16) - 1
            if label_data.roll then
                roll_kick = index
            else
                regular_kick = index
            end
        end
    end
    
    return roll_kick or regular_kick
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

local function validate_required_slices(saved_labels)
    local has_kick = false
    local has_roll_snare = false
    local has_ghost_snare = false
    local has_closed_hat = false
    
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == "Kick" then
            has_kick = true
        elseif label_data.label == "Snare" and label_data.roll then
            has_roll_snare = true
        elseif label_data.label == "Snare" and label_data.ghost_note then
            has_ghost_snare = true
        elseif label_data.label == "Hi Hat Closed" then
            has_closed_hat = true
        end
    end
    
    if not (has_kick and has_roll_snare and has_ghost_snare and has_closed_hat) then
        local missing = {}
        if not has_kick then table.insert(missing, "Kick") end
        if not has_roll_snare then table.insert(missing, "Snare with Roll") end
        if not has_ghost_snare then table.insert(missing, "Snare with Ghost Note") end
        if not has_closed_hat then table.insert(missing, "Hi Hat Closed") end
        
        local dialog_content = vb:column {
            margin = 10,
            vb:text { 
                text = "Missing required slices:"
            },
            vb:text {
                text = table.concat(missing, "\n"),
                font = "mono"
            }
        }
        renoise.app():show_custom_dialog("Missing Required Slices", dialog_content)
        return false
    end
    return true
end

local function get_hihat_slice(saved_labels, prefer_open)
    local closed_slice = nil
    local open_slice = nil
    
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == "Hi Hat Closed" then
            closed_slice = tonumber(hex_key, 16) - 1
        elseif label_data.label == "Hi Hat Open" then
            open_slice = tonumber(hex_key, 16) - 1
        end
    end
    
    if prefer_open and open_slice then
        return open_slice
    end
    return closed_slice
end

local function get_beat_slices(saved_labels, label)
    local slices = {primary = {}, ghost = {}}
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == label then
            local index = tonumber(hex_key, 16) - 1
            if label_data.roll then
                table.insert(slices.primary, index)
            elseif label_data.ghost_note then
                table.insert(slices.ghost, index)
            end
        end
    end
    return slices
end

local function apply_beat_pattern(phrase, pattern_table, saved_labels, steps)
    local parsed_patterns = {}
    local column_mapping = {} 
    local col_index = 1
    
    for pattern_type, pattern_str in pairs(pattern_table) do
        if pattern_type ~= "steps" then
            parsed_patterns[pattern_type] = parse_pattern_string(pattern_str)
            column_mapping[pattern_type] = col_index
            
            local column_label = ""
            if pattern_type == "K" then column_label = "Kick"
            elseif pattern_type == "S" then column_label = "Snare"
            elseif pattern_type == "G" then column_label = "Ghost"
            elseif pattern_type == "H" then column_label = "HiHat"
            elseif pattern_type == "O" then column_label = "OpHat"
            end
            
            phrase:set_column_name(col_index, column_label)
            col_index = col_index + 1
        end
    end
    
    local instrument_map = {}
    instrument_map["K"] = get_kick_slice(saved_labels)
    for hex_key, label_data in pairs(saved_labels) do
        local index = tonumber(hex_key, 16) - 1
        if label_data.label == "Snare" and label_data.roll then
            instrument_map["S"] = index
        elseif label_data.label == "Snare" and label_data.ghost_note then
            instrument_map["G"] = index
        end
    end
    instrument_map["H"] = get_hihat_slice(saved_labels, false)
    instrument_map["O"] = get_hihat_slice(saved_labels, true) or get_hihat_slice(saved_labels, false)
    
    for source_line = 1, steps do
        local target_line = (source_line - 1) * 4 + 1
        local line = phrase:line(target_line)
        
        for i = 1, #column_mapping do
            line:note_column(i):clear()
        end
        
        for pattern_type, column in pairs(column_mapping) do
            local pattern = parsed_patterns[pattern_type]
            if pattern[source_line] ~= "." then
                local note_column = line:note_column(column)
                note_column.note_value = 48 -- C-4
                note_column.instrument_value = instrument_map[pattern_type]
                
                if parsed_patterns["V"] then
                    local vol = parsed_patterns["V"][source_line]
                    if vol and vol:match("%d") then
                        note_column.volume_value = tonumber(vol .. "0", 16)
                    end
                end
            end
        end
        
        if target_line + 1 <= phrase.number_of_lines then
            for i = 1, 3 do
                local next_line = phrase:line(target_line + i)
                for j = 1, #column_mapping do
                    next_line:note_column(j):clear()
                end
            end
        end
    end
    
    -- Apply decay compensation after pattern generation
    utils.apply_decay_compensation(phrase)
end

local function create_timing_variation(instrument, base_phrase, division)
    local new_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    new_phrase:copy_from(base_phrase)
    new_phrase.name = string.format("%s 1/%d", base_phrase.name, division)
    new_phrase.lpb = math.ceil(base_phrase.lpb * (division / 8))
    
    -- Apply decay compensation to timing variations
    utils.apply_decay_compensation(new_phrase)
    
    return new_phrase
end

function beats.create_beat_patterns(instrument, original_phrase, saved_labels)
    if not validate_required_slices(saved_labels) then
        return {}, {} 
    end
    
    local all_phrases = {}
    local instruments_created = {}
    
    for name, pattern in pairs(templates) do
        local flag = string.match(name, "_([luajf])_")
        if flag then
            local steps = pattern.steps or 16
            
            local flag_instrument = instruments_created[flag]
            if not flag_instrument then
                flag_instrument = create_instrument_for_flag(instrument, flag)
                instruments_created[flag] = flag_instrument
            end
            
            local patterns_to_process = {
                {pattern = pattern, name_prefix = ""},
                {pattern = create_inverted_pattern(pattern), name_prefix = "Inverted "}
            }
            
            for _, pattern_variant in ipairs(patterns_to_process) do
                local base_phrase = flag_instrument:insert_phrase_at(#flag_instrument.phrases + 1)
                base_phrase:copy_from(original_phrase)
                base_phrase.number_of_lines = steps * 4
                base_phrase.name = string.format("%s%s", 
                    pattern_variant.name_prefix, 
                    name)
                utils.clear_phrase(base_phrase)
                
                apply_beat_pattern(base_phrase, pattern_variant.pattern, saved_labels, steps)
                utils.humanize_phrase(base_phrase)
                table.insert(all_phrases, base_phrase)
                
                for _, division in ipairs({4, 6, 12, 16}) do
                    local variation = create_timing_variation(flag_instrument, base_phrase, division)
                    utils.humanize_phrase(variation)
                    table.insert(all_phrases, variation)
                end
            end
        end
    end
    
    return all_phrases, instruments_created
end

function beats.show_results(new_phrases, created_instruments)
    local info = "Created Beat Patterns:\n\n"
    
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
        vb:text { text = "Beat Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
    renoise.app():show_custom_dialog("Beat Pattern Results", dialog_content)
end

return beats