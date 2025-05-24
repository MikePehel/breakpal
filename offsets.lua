-- offsets.lua
local offsets = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")

local curve_types = {"linear", "logarithmic", "exponential"}
local advanced_curve_types = {"upParabola", "downParabola", "doublePeak", "doubleValley"}
local timing_divisions = {4, 6, 8, 12, 16}

local function create_instrument_for_label(base_instrument, label)
    local song = renoise.song()
    local new_instrument = duplicator.duplicate_instrument(string.format("%s Sample Offsets", label), 0)
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function create_advanced_instrument_for_label(base_instrument, label)
    local song = renoise.song()
    local new_instrument = duplicator.duplicate_instrument(string.format("%s Advanced Offsets", label), 0)
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function get_roll_slices(saved_labels)
    local roll_slices = {}
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.roll then
            local index = tonumber(hex_key, 16) - 1
            table.insert(roll_slices, {
                index = index,
                label = label_data.label
            })
        end
    end
    return roll_slices
end

local function apply_offset_pattern(phrase, slice_index, curve_values, line_interval)
    utils.clear_phrase(phrase)
    
    local note_count = 0
    for i = 1, phrase.number_of_lines, line_interval do
        note_count = note_count + 1
        local line = phrase:line(i)
        local note_column = line:note_column(1)
        local effect_column = line:effect_column(1)
        
        -- Set the note
        note_column.note_value = 48  -- C-4
        note_column.instrument_value = slice_index
        
        -- Apply S-command with curve value
        if note_count <= #curve_values then
            effect_column.number_string = "0S"
            effect_column.amount_value = curve_values[note_count]
        end
    end
    
    -- Apply humanization and decay compensation
    utils.humanize_phrase(phrase)
    utils.apply_decay_compensation(phrase)
end

local function create_base_offset_phrase(instrument, original_phrase, slice, curve_type, inverse)
    local base_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    base_phrase:copy_from(original_phrase)
    base_phrase.number_of_lines = 32
    
    local name_prefix = inverse and "Inverse " or ""
    base_phrase.name = string.format("%s Offset %s%s Base", slice.label, name_prefix, curve_type)
    
    -- Generate curve values (16 notes, mapped to 0-255 range for S-command)
    local start_val = inverse and 255 or 0
    local end_val = inverse and 0 or 255
    local curve_values = utils.generate_curve(curve_type, start_val, end_val, 16)
    
    apply_offset_pattern(base_phrase, slice.index, curve_values, 2)
    
    return base_phrase
end

local function create_2x_offset_phrase(instrument, original_phrase, slice, curve_type, inverse)
    local phrase_2x = instrument:insert_phrase_at(#instrument.phrases + 1)
    phrase_2x:copy_from(original_phrase)
    phrase_2x.number_of_lines = 64
    
    local name_prefix = inverse and "Inverse " or ""
    phrase_2x.name = string.format("%s Offset %s%s 2x", slice.label, name_prefix, curve_type)
    
    -- Generate curve values (16 notes, mapped to 0-255 range for S-command)
    local start_val = inverse and 255 or 0
    local end_val = inverse and 0 or 255
    local curve_values = utils.generate_curve(curve_type, start_val, end_val, 16)
    
    apply_offset_pattern(phrase_2x, slice.index, curve_values, 4)
    
    return phrase_2x
end

local function create_timing_variation(instrument, base_phrase, division)
    local new_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    new_phrase:copy_from(base_phrase)
    new_phrase.name = string.format("%s 1/%d", base_phrase.name, division)
    
    local base_lpb = base_phrase.lpb
    new_phrase.lpb = math.ceil(base_lpb * (division / 8))
    
    utils.humanize_phrase(new_phrase)
    utils.apply_decay_compensation(new_phrase)
    
    return new_phrase
end

function offsets.create_offset_patterns(instrument, original_phrase, saved_labels)
    local all_phrases = {}
    local instruments_created = {}
    
    local roll_slices = get_roll_slices(saved_labels)
    
    if #roll_slices == 0 then
        renoise.app():show_warning("No slices found with Roll flag. Please label some slices with the Roll flag first.")
        return all_phrases, instruments_created
    end
    
    -- Group slices by label
    local slices_by_label = {}
    for _, slice in ipairs(roll_slices) do
        local label = slice.label or "Unknown"
        if not slices_by_label[label] then
            slices_by_label[label] = {}
        end
        table.insert(slices_by_label[label], slice)
    end
    
    -- Create basic instruments and phrases for each label
    for label, slices in pairs(slices_by_label) do
        local label_instrument = create_instrument_for_label(instrument, label)
        instruments_created[label] = label_instrument
        
        for _, slice in ipairs(slices) do
            for _, curve_type in ipairs(curve_types) do
                -- Create normal curves
                -- Create base phrase (32 lines, every 2 lines)
                local base_phrase = create_base_offset_phrase(label_instrument, original_phrase, slice, curve_type, false)
                table.insert(all_phrases, base_phrase)
                
                -- Create timing variations for base phrase
                for _, division in ipairs(timing_divisions) do
                    local variation = create_timing_variation(label_instrument, base_phrase, division)
                    table.insert(all_phrases, variation)
                end
                
                -- Create 2x phrase (64 lines, every 4 lines)
                local phrase_2x = create_2x_offset_phrase(label_instrument, original_phrase, slice, curve_type, false)
                table.insert(all_phrases, phrase_2x)
                
                -- Create timing variations for 2x phrase
                for _, division in ipairs(timing_divisions) do
                    local variation_2x = create_timing_variation(label_instrument, phrase_2x, division)
                    table.insert(all_phrases, variation_2x)
                end
                
                -- Create inverse curves
                -- Create inverse base phrase (32 lines, every 2 lines)
                local inverse_base_phrase = create_base_offset_phrase(label_instrument, original_phrase, slice, curve_type, true)
                table.insert(all_phrases, inverse_base_phrase)
                
                -- Create timing variations for inverse base phrase
                for _, division in ipairs(timing_divisions) do
                    local inverse_variation = create_timing_variation(label_instrument, inverse_base_phrase, division)
                    table.insert(all_phrases, inverse_variation)
                end
                
                -- Create inverse 2x phrase (64 lines, every 4 lines)
                local inverse_phrase_2x = create_2x_offset_phrase(label_instrument, original_phrase, slice, curve_type, true)
                table.insert(all_phrases, inverse_phrase_2x)
                
                -- Create timing variations for inverse 2x phrase
                for _, division in ipairs(timing_divisions) do
                    local inverse_variation_2x = create_timing_variation(label_instrument, inverse_phrase_2x, division)
                    table.insert(all_phrases, inverse_variation_2x)
                end
            end
        end
    end
    
    -- Create advanced instruments and phrases for each label
    for label, slices in pairs(slices_by_label) do
        local advanced_instrument = create_advanced_instrument_for_label(instrument, label)
        instruments_created[label .. "_Advanced"] = advanced_instrument
        
        for _, slice in ipairs(slices) do
            for _, curve_type in ipairs(advanced_curve_types) do
                -- Create base phrase (32 lines, every 2 lines)
                local base_phrase = create_base_offset_phrase(advanced_instrument, original_phrase, slice, curve_type, false)
                table.insert(all_phrases, base_phrase)
                
                -- Create timing variations for base phrase
                for _, division in ipairs(timing_divisions) do
                    local variation = create_timing_variation(advanced_instrument, base_phrase, division)
                    table.insert(all_phrases, variation)
                end
                
                -- Create 2x phrase (64 lines, every 4 lines)
                local phrase_2x = create_2x_offset_phrase(advanced_instrument, original_phrase, slice, curve_type, false)
                table.insert(all_phrases, phrase_2x)
                
                -- Create timing variations for 2x phrase
                for _, division in ipairs(timing_divisions) do
                    local variation_2x = create_timing_variation(advanced_instrument, phrase_2x, division)
                    table.insert(all_phrases, variation_2x)
                end
            end
        end
    end
    
    return all_phrases, instruments_created
end

function offsets.show_results(new_phrases, created_instruments)
    local info = "Created Sample Offset Patterns:\n\n"
    
    if created_instruments then
        info = info .. "Created Instruments:\n"
        for label, instrument in pairs(created_instruments) do
            info = info .. string.format("- %s (%d patterns)\n", 
                instrument.name, 
                #instrument.phrases)
        end
        info = info .. "\n"
        info = info .. string.format("Total patterns created: %d\n", #new_phrases)
        info = info .. string.format("Patterns per slice: Base + 2x + timing variations (1/4, 1/6, 1/8, 1/12, 1/16 for each)\n")
        info = info .. string.format("Each pattern created in normal and inverse versions\n")
        info = info .. string.format("Basic Curve types: %s\n\n", table.concat(curve_types, ", "))
        info = info .. string.format("Advanced curve types: %s\n\n", table.concat(advanced_curve_types, ", "))
    end
    
    info = info .. "Pattern Details:\n"
    for i, phrase in ipairs(new_phrases) do
        info = info .. string.format("Phrase %d: %s\n", i, phrase.name)
        info = info .. string.format("  Lines: %d\n", phrase.number_of_lines)
        
        -- Show first few notes with their S-command values
        local note_count = 0
        for line_idx = 1, math.min(phrase.number_of_lines, 16) do
            local line = phrase:line(line_idx)
            local note_column = line:note_column(1)
            local effect_column = line:effect_column(1)
            
            if note_column.note_value ~= 121 then -- Not empty
                note_count = note_count + 1
                info = info .. string.format("    Line %02d: Instrument %02d, S-Command %02X\n", 
                    line_idx - 1, 
                    note_column.instrument_value,
                    effect_column.amount_value)
                
                if note_count >= 4 then -- Show first 4 notes only
                    info = info .. "    ...\n"
                    break
                end
            end
        end
        info = info .. "\n"
    end
    
    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Sample Offset Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
    renoise.app():show_custom_dialog("Sample Offset Pattern Results", dialog_content)
end

return offsets