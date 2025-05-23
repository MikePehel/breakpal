local rollers = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")

local augmentation_types = {"Upshift", "Downshift", "Stretch", "Staccato", "Backwards", "Reversal"}
local curve_types = {"linear", "logarithmic", "exponential"}

-- Helper functions
local function note_value_to_string(note_value)
    if note_value == 120 then return "OFF"
    elseif note_value == 121 then return "---"
    else
        local octave = math.floor(note_value / 12) - 2
        local note_names = {"C-", "C#", "D-", "D#", "E-", "F-", "F#", "G-", "G#", "A-", "A#", "B-"}
        local note_index = (note_value % 12) + 1
        return string.format("%s%d", note_names[note_index], octave)
    end
end

local function generate_permutations(roll_slices, ghost_slices)
    local permutations = {}
    for _, roll in ipairs(roll_slices) do
        for _, ghost in ipairs(ghost_slices) do
            if roll ~= ghost then 
                table.insert(permutations, {roll = roll, ghost = ghost})
            end
        end
    end
    return permutations
end

local function group_permutations_by_label(permutations)
    local grouped = {}
    for _, perm in ipairs(permutations) do
        if perm.label then  
            grouped[perm.label] = grouped[perm.label] or {}
            table.insert(grouped[perm.label], perm)
        end
    end
    return grouped
end

-- Main functions
function rollers.create_beat_divisions_on_patterns(instrument, source_phrase_index, beat_division)
    local source_phrase = instrument.phrases[source_phrase_index]
    local new_phrase = instrument:insert_phrase_at(source_phrase_index + 1)
    new_phrase:copy_from(source_phrase)
    new_phrase.name = string.format("%s 1/%d", source_phrase.name, beat_division)

    if beat_division < 6 then
        local multiplier = math.ceil(8 / beat_division)
        local original_length = new_phrase.number_of_lines
        new_phrase.number_of_lines = original_length * multiplier

        for line_index = original_length + 1, new_phrase.number_of_lines do
            new_phrase:line(line_index):clear()
        end

        for line_index = original_length, 1, -1 do
            local new_line_index = (line_index - 1) * multiplier + 1
            if new_line_index ~= line_index then
                new_phrase:line(new_line_index):copy_from(new_phrase:line(line_index))
                new_phrase:line(line_index):clear()
            end
        end
    else
        local multiplier = beat_division == 6 and 0.75 or (beat_division / 8)
        new_phrase.lpb = math.ceil(source_phrase.lpb * multiplier)
    end
    utils.humanize_phrase(new_phrase)
    utils.apply_decay_compensation(new_phrase)
    return new_phrase
end

function rollers.create_alternating_patterns(instrument, original_phrase, saved_labels)
    local song = renoise.song()
    local lpb = song.transport.lpb
    local new_phrases = {}
    local unique_labels = {}
    local all_permutations = {}

    for _, label_data in pairs(saved_labels) do
        unique_labels[label_data.label] = true
    end

    for label in pairs(unique_labels) do
        local slices = utils.get_slices_by_label(saved_labels, label)
        if #slices.roll > 0 and #slices.ghost > 0 then
            local label_permutations = generate_permutations(slices.roll, slices.ghost)
            for _, perm in ipairs(label_permutations) do
                table.insert(all_permutations, {
                    label = label,
                    roll = perm.roll,
                    ghost = perm.ghost
                })
            end
        end
    end

    local new_instrument = duplicator.duplicate_instrument(instrument.name.."Base", 0)

    local phrase_index = #instrument.phrases + 1
    for label, label_perms in pairs(group_permutations_by_label(all_permutations)) do
        print("LABEL FOR DUPLIACTION")
        print(label)
        for i, perm in ipairs(label_perms) do
            for _, division in ipairs({2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64}) do
                local new_instrument = duplicator.duplicate_instrument(label..i, division)
                local current_index = song.selected_instrument_index                
                print("CURRENT INDEX")
                print(current_index)
                print("PHRASE INDEX")
                print(phrase_index)
                local new_variation_phrase = rollers.create_beat_divisions_on_patterns(new_instrument, 1, division)
                new_variation_phrase.name = string.format("%s Rolls Alt %d", label, i)
                print("PHRASE LPB")
                print(new_variation_phrase.lpb)
                print("PHRASE ")
                print(new_variation_phrase.number_of_lines)
                utils.clear_phrase(new_variation_phrase)
                if division < 6 then
                    rollers.add_alternating_notes(new_variation_phrase, new_variation_phrase.number_of_lines, perm)
                else
                    new_variation_phrase.number_of_lines = lpb
                    rollers.add_alternating_notes(new_variation_phrase, lpb, perm)
                end
                
                utils.humanize_phrase(new_variation_phrase)
                utils.apply_decay_compensation(new_variation_phrase)
                table.insert(new_phrases, new_variation_phrase)

                local ext_phrase = rollers.create_extended_phrase(new_instrument, new_variation_phrase)
                if ext_phrase then
                    print(ext_phrase)
                    utils.humanize_phrase(ext_phrase)
                    utils.apply_decay_compensation(ext_phrase)
                    table.insert(new_phrases, ext_phrase)
    
                    rollers.create_curve_phrases(new_instrument, ext_phrase, new_phrases, label)
    
                    rollers.create_augmented_phrases(new_instrument, ext_phrase, new_phrases, "(2x)")
                end

            end
        
        end
    end

    return new_phrases 
end

function rollers.add_alternating_notes(phrase, lpb, perm)
    local half_beat = math.floor(lpb / 2)
    local roll_note = phrase:line(1):note_column(1)
    local ghost_note = phrase:line(half_beat + 1):note_column(1)

    roll_note.note_value = 48
    roll_note.instrument_value = perm.roll
    ghost_note.note_value = 48
    ghost_note.instrument_value = perm.ghost
end

function rollers.create_roll_patterns(instrument, original_phrase, saved_labels)
    local song = renoise.song()
    local lpb = song.transport.lpb
    local roll_patterns = {}
    local roll_slices = rollers.get_roll_slices(saved_labels)

    local phrase_index = #instrument.phrases + 1
    for i, slice in ipairs(roll_slices) do
        local basic_phrase = rollers.create_basic_roll_phrase(instrument, original_phrase, slice, lpb, i)
        if basic_phrase then
            table.insert(roll_patterns, basic_phrase)
            rollers.create_extended_roll_patterns(instrument, basic_phrase, roll_patterns, phrase_index, slice, lpb)
            phrase_index = phrase_index + 45 + (#curve_types * 2)
        end
    end

    return roll_patterns 
end

function rollers.get_roll_slices(saved_labels)
    local roll_slices = {}
    for key, label_data in pairs(saved_labels) do
        if label_data.roll then
            local index = tonumber(key, 16)
            if index then
                table.insert(roll_slices, {index = index - 1, label = label_data.label})
            else
                print("Warning: Invalid key format. Key:", key)
            end
        end
    end
    return roll_slices
end

function rollers.create_basic_roll_phrase(instrument, original_phrase, slice, lpb, index)
    local basic_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    basic_phrase:copy_from(original_phrase)
    basic_phrase.name = string.format("%s Roll Basic %02d", slice.label, index)
    basic_phrase.number_of_lines = lpb

    utils.clear_phrase(basic_phrase)

    local original_note = rollers.find_original_note(original_phrase, slice.index)
    if original_note then
        rollers.add_basic_roll_notes(basic_phrase, original_note, slice.index, lpb)
        utils.humanize_phrase(basic_phrase)
        utils.apply_decay_compensation(basic_phrase)
        return basic_phrase
    else
        print("Warning: No note found for slice index", slice.index, "Label:", slice.label)
        return nil
    end
end

function rollers.find_original_note(phrase, slice_index)
    for _, line in ipairs(phrase.lines) do
        for _, note_column in ipairs(line.note_columns) do
            if note_column.instrument_value == slice_index then
                return note_column
            end
        end
    end
    return nil
end

function rollers.add_basic_roll_notes(phrase, original_note, slice_index, lpb)
    local first_note = phrase:line(1):note_column(1)
    local second_note = phrase:line(math.floor(lpb/2) + 1):note_column(1)
    
    if first_note and second_note then
        first_note.note_value = original_note.note_value
        first_note.instrument_value = slice_index
        
        local volume = original_note.volume_value ~= 255 and original_note.volume_value or 128
        first_note.volume_value = volume
        second_note.note_value = original_note.note_value
        second_note.instrument_value = slice_index
        second_note.volume_value = math.floor(volume / 2)
    end
end

function rollers.create_extended_roll_patterns(instrument, basic_phrase, roll_patterns, phrase_index, slice, lpb)
    local basic_2x_phrase = rollers.create_2x_phrase(instrument, basic_phrase)
    if basic_2x_phrase then
        table.insert(roll_patterns, basic_2x_phrase)
        rollers.create_curve_phrases(instrument, basic_2x_phrase, roll_patterns)
        rollers.create_variation_phrases(instrument, basic_phrase, roll_patterns, phrase_index)
    end
end

function rollers.create_2x_phrase(instrument, basic_phrase)
    local basic_2x_phrase = duplicator.duplicate_phrases(instrument, basic_phrase, 1)[1]
    if basic_2x_phrase and utils.multiply_phrase_length then
        basic_2x_phrase = utils.multiply_phrase_length(basic_2x_phrase, 2)
        basic_2x_phrase.name = string.format("%s (2x)", basic_phrase.name)
        utils.humanize_phrase(basic_2x_phrase)
        utils.apply_decay_compensation(basic_2x_phrase)
        return basic_2x_phrase
    else
        print("Warning: Failed to create 2x version of basic phrase or multiply_phrase_length function not found")
        return nil
    end
end

function rollers.create_curve_phrases(instrument, basic_2x_phrase, roll_patterns, label)
    for _, curve_type in ipairs(curve_types) do
        local curve_phrase = rollers.create_curve_phrase(instrument, basic_2x_phrase, curve_type, false)
        if curve_phrase then
            table.insert(roll_patterns, curve_phrase)
            rollers.create_augmented_phrases(instrument, curve_phrase, roll_patterns, string.format("(%s)", curve_type))
        end

        local inverse_curve_phrase = rollers.create_curve_phrase(instrument, basic_2x_phrase, curve_type, true)
        if inverse_curve_phrase then
            table.insert(roll_patterns, inverse_curve_phrase)
            rollers.create_augmented_phrases(instrument, inverse_curve_phrase, roll_patterns, string.format("(Inverse %s)", curve_type))
        end
    end
end

function rollers.create_curve_phrase(instrument, basic_2x_phrase, curve_type, inverse)
    local curve_phrase = duplicator.duplicate_phrases(instrument, basic_2x_phrase, 1)[1]
    if curve_phrase then
        curve_phrase.name = string.format("%s (%s%s)", basic_2x_phrase.name, inverse and "Inverse " or "", curve_type)
        
        local volume = rollers.get_phrase_volume(basic_2x_phrase)
        local start_volume, end_volume = inverse and math.floor(volume / 4) or volume, inverse and volume or math.floor(volume / 4)
        local volume_curve = utils.generate_curve(curve_type, start_volume, end_volume, 4)

        rollers.apply_volume_curve(curve_phrase, volume_curve)
        utils.humanize_phrase(curve_phrase)
        utils.apply_decay_compensation(curve_phrase)
        return curve_phrase
    else
        print(string.format("Warning: Failed to create %scurve phrase for %s", inverse and "inverse " or "", curve_type))
        return nil
    end
end

function rollers.get_phrase_volume(phrase)
    for _, line in ipairs(phrase.lines) do
        local note_column = line:note_column(1)
        if note_column.note_value ~= 121 and note_column.volume_value ~= 255 then
            return note_column.volume_value
        end
    end
    return 128  -- Default volume if not found
end

function rollers.apply_volume_curve(phrase, volume_curve)
    local curve_index = 1
    for _, line in ipairs(phrase.lines) do
        local note_column = line:note_column(1)
        if note_column.note_value ~= 121 then  
            note_column.volume_value = volume_curve[curve_index]
            curve_index = (curve_index % #volume_curve) + 1
        end
    end
end

function rollers.create_augmented_phrases(instrument, source_phrase, roll_patterns, name_suffix)
    for _, augmentation in ipairs(augmentation_types) do
        local augmented_phrase = duplicator.duplicate_phrases(instrument, source_phrase, 1)[1]
        utils.augment_phrase(augmentation, augmented_phrase)
        augmented_phrase.name = string.format("%s %s %s", source_phrase.name, "", augmentation)
        utils.humanize_phrase(augmented_phrase)
        utils.apply_decay_compensation(augmented_phrase)
        table.insert(roll_patterns, augmented_phrase)
    end
end

function rollers.create_variation_phrases(instrument, basic_phrase, roll_patterns, phrase_index)
    for _, division in ipairs({2, 3, 4, 6, 12, 16, 24, 32, 48, 64}) do
        local new_variation_phrase = rollers.create_beat_divisions_on_patterns(instrument, phrase_index, division)
        if new_variation_phrase then
            utils.humanize_phrase(new_variation_phrase)
            table.insert(roll_patterns, new_variation_phrase)
            rollers.create_extended_variation_phrases(instrument, new_variation_phrase, roll_patterns)
        else
            print("Warning: Failed to create variation for division", division)
        end
    end
end

function rollers.create_extended_variation_phrases(instrument, variation_phrase, roll_patterns)
    local extended_phrase = rollers.create_extended_phrase(instrument, variation_phrase)
    if extended_phrase then
        table.insert(roll_patterns, extended_phrase)
        rollers.create_augmented_phrases(instrument, extended_phrase, roll_patterns, "(2x)")
        rollers.create_curve_phrases(instrument, extended_phrase, roll_patterns)
    end
end

function rollers.create_extended_phrase(instrument, source_phrase)
    local extended_phrase = duplicator.duplicate_phrases(instrument, source_phrase, 1)[1]
    if extended_phrase and utils.multiply_phrase_length then
        extended_phrase = utils.multiply_phrase_length(extended_phrase, 2)
        extended_phrase.name = string.format("%s (2x)", source_phrase.name)
        utils.humanize_phrase(extended_phrase)
        utils.apply_decay_compensation(extended_phrase)
        return extended_phrase
    else
        print("Warning: Failed to extend phrase or multiply_phrase_length function not found")
        return nil
    end
end

function rollers.show_results(new_phrases)
    local info = "Created Alternating Patterns:\n\n"
    
    for i, phrase in ipairs(new_phrases) do
        info = info .. string.format("Phrase %d: %s\n", i, phrase.name)
        info = info .. "  Lines:\n"
        
        for line_index, line in ipairs(phrase.lines) do
            local note_column = line:note_column(1)
            if note_column.note_value ~= 121 then
                info = info .. string.format("    %02d %s %02d\n", 
                    line_index - 1, 
                    note_value_to_string(note_column.note_value),
                    note_column.instrument_value)
            end
        end
        
        info = info .. "\n"
    end

    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Alternating Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }

end

return rollers
