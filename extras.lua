-- extras.lua
local extras = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")
local templates = require("templates")
local config = require("config")
local settings = require("settings")

local function create_instrument_for_label_and_flag(base_instrument, label, flag_name)
    local song = renoise.song()
    local new_instrument = duplicator.duplicate_instrument(string.format("%s %s", label, flag_name), 0)
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function get_roll_ghost_pairs(saved_labels, label)
    local roll_slices = {}
    local ghost_slices = {}
    
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == label then
            local index = tonumber(hex_key, 16) - 1
            if label_data.roll then
                table.insert(roll_slices, index)
            elseif label_data.ghost_note then
                table.insert(ghost_slices, index)
            end
        end
    end
    
    local pairs = {
        roll = {},
        ghost = {}
    }
    
    -- Generate roll pairs
    if #roll_slices >= 2 then
        for i = 1, #roll_slices - 1 do
            for j = i + 1, #roll_slices do
                table.insert(pairs.roll, {
                    primary = roll_slices[i],
                    secondary = roll_slices[j]
                })
            end
        end
    end
    
    -- Generate ghost pairs
    if #ghost_slices >= 2 then
        for i = 1, #ghost_slices - 1 do
            for j = i + 1, #ghost_slices do
                table.insert(pairs.ghost, {
                    primary = ghost_slices[i],
                    secondary = ghost_slices[j]
                })
            end
        end
    end
    
    return pairs
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

local function apply_pattern_with_pairs(phrase, pattern_table, pair, pair_type, steps)
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
            note_column.note_value = 48  -- C-4
            note_column.instrument_value = pair.primary
        elseif parsed_patterns["L"] and parsed_patterns["L"][source_line] == "L" then
            note_column.note_value = 48  -- C-4
            note_column.instrument_value = pair.secondary
        end
        
        -- Apply volume if specified
        if parsed_patterns["V"] and parsed_patterns["V"][source_line] ~= "." then
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
    
    local base_lpb = base_phrase.lpb
    new_phrase.lpb = math.ceil(base_lpb * (division / 8))
    
    return new_phrase
end


local function create_pattern_set(instrument, original_phrase, template_name, pattern, pairs, label)
    local new_phrases = {}
    local steps = pattern.steps or 16
    
    local patterns_to_process = {
        {pattern = pattern, name_prefix = ""},
        {pattern = create_inverted_pattern(pattern), name_prefix = "Inverted "}
    }
    
    for _, pattern_variant in ipairs(patterns_to_process) do
        for i, pair in ipairs(pairs.roll) do
            local base_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
            base_phrase:copy_from(original_phrase)
            base_phrase.number_of_lines = steps * 4
            base_phrase.name = string.format("%s%s Roll %s %d", 
                pattern_variant.name_prefix, template_name, label, i)
            utils.clear_phrase(base_phrase)
            
            apply_pattern_with_pairs(base_phrase, pattern_variant.pattern, pair, "Roll", steps)
            utils.humanize_phrase(base_phrase)
            utils.apply_decay_compensation(base_phrase)
            table.insert(new_phrases, base_phrase)
            
            local divisions = settings.get("timing_divisions", "standard")
            for _, division in ipairs(divisions) do
                local variation = create_timing_variation(instrument, base_phrase, division)
                utils.humanize_phrase(variation)
                utils.apply_decay_compensation(variation)
                table.insert(new_phrases, variation)
            end
        end
        
        for i, pair in ipairs(pairs.ghost) do
            local base_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
            base_phrase:copy_from(original_phrase)
            base_phrase.number_of_lines = steps * 4
            base_phrase.name = string.format("%s%s Ghost %s %d", 
                pattern_variant.name_prefix, template_name, label, i)
            utils.clear_phrase(base_phrase)
            
            apply_pattern_with_pairs(base_phrase, pattern_variant.pattern, pair, "Ghost", steps)
            utils.humanize_phrase(base_phrase)
            utils.apply_decay_compensation(base_phrase)
            table.insert(new_phrases, base_phrase)
            
            local divisions = settings.get("timing_divisions", "standard")
            for _, division in ipairs(divisions) do
                local variation = create_timing_variation(instrument, base_phrase, division)
                utils.humanize_phrase(variation)
                utils.apply_decay_compensation(variation)
                table.insert(new_phrases, variation)
            end
        end
    end
    
    return new_phrases
end

function extras.create_pattern_variations(instrument, original_phrase, saved_labels)
    local all_phrases = {}
    local song = renoise.song()
    
    local instruments_by_flag_and_label = {
        p = {}, -- Paradiddles
        c = {}, -- Crossovers
        r = {}  -- Complex Rolls
    }

    local flag_names = config.EXTRAS_TYPES
    
    local unique_labels = {}
    local seen = {}
    for _, label_data in pairs(saved_labels) do
        if not seen[label_data.label] then
            seen[label_data.label] = true
            table.insert(unique_labels, label_data.label)
        end
    end
    
    local extras_patterns = templates.get_extras_patterns(settings.get_enabled_extras_types())
    
    for name, pattern in pairs(extras_patterns) do
        local meta = templates.metadata[name]
        if meta and meta.category then
            local flag = meta.category

            for _, label in ipairs(unique_labels) do
                local pairs = get_roll_ghost_pairs(saved_labels, label)
                
                if #pairs.roll > 0 or #pairs.ghost > 0 then
                    if not instruments_by_flag_and_label[flag][label] then
                        instruments_by_flag_and_label[flag][label] = create_instrument_for_label_and_flag(
                            instrument,
                            label,
                            flag_names[flag]
                        )
                    end
                    
                    local target_instrument = instruments_by_flag_and_label[flag][label]

                    local variations = create_pattern_set(
                        target_instrument,
                        original_phrase,
                        name,
                        pattern,
                        pairs,
                        label
                    )
                    
                    for _, phrase in ipairs(variations) do
                        table.insert(all_phrases, phrase)
                    end
                end
            end
        end
    end
    
    return all_phrases, instruments_by_flag_and_label
end

function extras.show_results(new_phrases, instruments_by_flag_and_label)
    local info = "Created Pattern Variations:\n\n"
    
    if instruments_by_flag_and_label then
        info = info .. "Created Instruments:\n"
        for flag, label_instruments in pairs(instruments_by_flag_and_label) do
            for label, instrument in pairs(label_instruments) do
                info = info .. string.format("- %s (%d patterns)\n", 
                    instrument.name, 
                    #instrument.phrases)
            end
        end
        info = info .. "\n"
    end
    
    info = info .. "Pattern Details:\n"
    for i, phrase in ipairs(new_phrases) do
        info = info .. string.format("Phrase %d: %s\n", i, phrase.name)
        info = info .. string.format("  Lines: %d, LPB: %d\n", 
            phrase.number_of_lines, phrase.lpb)
            
        info = info .. "  Pattern:\n"
        for line_index = 1, phrase.number_of_lines do
            local note_column = phrase:line(line_index):note_column(1)
            if note_column.note_value ~= 121 then
                info = info .. string.format("    %2d: Instrument %2d Volume %2d\n", 
                    line_index - 1, 
                    note_column.instrument_value,
                    note_column.volume_value)
            end
        end
        info = info .. "\n"
    end
    
    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Pattern Variations Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
    renoise.app():show_custom_dialog("Pattern Variation Results", dialog_content)
end

return extras