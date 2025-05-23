local shuffles = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")

local function get_slice_indices(saved_labels, type)
    local indices = {}
    for hex_key, label_data in pairs(saved_labels) do
        if type == "S" and label_data.label == "Snare" and 
           (label_data.shuffle or (label_data.shuffle and label_data.ghost_note)) then
            table.insert(indices, tonumber(hex_key, 16) - 1)
        elseif type == "G" and label_data.label == "Snare" and 
               label_data.ghost_note then
            table.insert(indices, tonumber(hex_key, 16) - 1)
        elseif type == "H" and label_data.label == "Hi Hat Closed" and 
               label_data.shuffle then
            table.insert(indices, tonumber(hex_key, 16) - 1)
        elseif type == "K" and label_data.label == "Kick" and 
            (label_data.shuffle or (label_data.shuffle and label_data.ghost_note)) then
             table.insert(indices, tonumber(hex_key, 16) - 1)  
        elseif type == "L" and label_data.label == "Kick" and
                label_data.ghost_note then
            table.insert(indices, tonumber(hex_key, 16) - 1)
        end
        
    end
    return indices
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

local function apply_layered_patterns(phrase, pattern_table, slice_indices)
    local parsed_patterns = {}

    for instrument_type, pattern_str in pairs(pattern_table) do
        parsed_patterns[instrument_type] = parse_pattern_string(pattern_str)
    end
    
    for source_line = 1, 16 do
        local target_line = (source_line - 1) * 4 + 1  
        local note_column = phrase:line(target_line):note_column(1)
        note_column:clear()
        
        for instrument_type, lines in pairs(parsed_patterns) do
            if lines[source_line] ~= "." and #slice_indices[instrument_type] > 0 then
                local slice_index = slice_indices[instrument_type][1]
                note_column.note_value = 48  -- C-4
                note_column.instrument_value = slice_index
                break  
            end
        end
        
        if target_line + 1 <= 64 then
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

local function create_shuffle_pattern_set(instrument, original_phrase, pattern_name, pattern_table, slice_indices)
    local new_phrases = {}
    
    local shuffle_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    shuffle_phrase:copy_from(original_phrase)
    shuffle_phrase.name = pattern_name .. " Base"
    shuffle_phrase.number_of_lines = 64  
    
    utils.clear_phrase(shuffle_phrase)
    
    apply_layered_patterns(shuffle_phrase, pattern_table, slice_indices)
    utils.humanize_phrase(shuffle_phrase)
    utils.apply_decay_compensation(shuffle_phrase)
    table.insert(new_phrases, shuffle_phrase)
    

    local divisions = {4, 6, 8, 12, 16}
    
    for _, division in ipairs(divisions) do
        local variation = create_timing_variation(instrument, shuffle_phrase, division)
        utils.humanize_phrase(variation)
        utils.apply_decay_compensation(variation)
        table.insert(new_phrases, variation)
    end
    
    return new_phrases
end

function shuffles.create_shuffles(instrument, original_phrase, saved_labels)
    local song = renoise.song()
    local templates = require("templates")
    local all_phrases = {}
    local label =  "Shuffles"
    local new_instrument = duplicator.duplicate_instrument(song.selected_instrument.name..label, 0)
    
    local slice_indices = {
        S = get_slice_indices(saved_labels, "S"),
        G = get_slice_indices(saved_labels, "G"),
        H = get_slice_indices(saved_labels, "H"),
        K = get_slice_indices(saved_labels, "K"),
        L = get_slice_indices(saved_labels, "L")
    }
    
    if #slice_indices.S == 0 and #slice_indices.G == 0 and #slice_indices.H == 0 then
        print("No slices found matching shuffle criteria")
        return all_phrases
    end
    
    local shuffle_types = {
        { name = "Basic Snare Hat", pattern = templates.basic_snare_hat_shuffle },
        { name = "Syncopated Ghost", pattern = templates.syncopated_ghost_shuffle },
        { name = "Hat Driven", pattern = templates.hat_driven_shuffle },
        { name = "Complex", pattern = templates.complex_shuffle },
        { name = "Triplet Feel", pattern = templates.triplet_feel_shuffle },
        { name = "Basic Kick Hat", pattern = templates.kick_hat_shuffle },
        { name = "Syncopated Kick", pattern = templates.syncopated_kick_shuffle },
        { name = "Ghost Kick", pattern = templates.ghost_kick_shuffle },
        { name = "Rolling Hat", pattern = templates.rolling_hat_shuffle },
        { name = "Kick Hat Interplay", pattern = templates.interplay_shuffle },
        { name = "Two Step", pattern = templates.two_step_shuffle },
        { name = "Syncopated Kick Snare", pattern = templates.syncopated_kick_snare_shuffle },
        { name = "Rolling Snare", pattern = templates.rolling_snare_shuffle },
        { name = "Complex Kick", pattern = templates.complex_kick_shuffle },
        { name = "Ghost Groove", pattern = templates.ghost_groove_shuffle }
    }
    
    for _, shuffle_type in ipairs(shuffle_types) do
        local new_phrases = create_shuffle_pattern_set(
            new_instrument,
            original_phrase,
            shuffle_type.name,
            shuffle_type.pattern,
            slice_indices
        )
        
        for _, phrase in ipairs(new_phrases) do
            table.insert(all_phrases, phrase)
        end
    end
    
    return all_phrases
end

function shuffles.show_results(new_phrases)
    local info = "Created Shuffle Patterns:\n\n"
    
    for i, phrase in ipairs(new_phrases) do
        info = info .. string.format("Phrase %d: %s\n", i, phrase.name)
        info = info .. string.format("  Lines: %d, LPB: %d\n", 
            phrase.number_of_lines, phrase.lpb)
            
        info = info .. "  Pattern:\n"
        for line_index = 1, phrase.number_of_lines do
            local note_column = phrase:line(line_index):note_column(1)
            if note_column.note_value ~= 121 then
                info = info .. string.format("    %2d: Instrument %2d\n", 
                    line_index - 1, note_column.instrument_value)
            else
                info = info .. string.format("    %2d: ----\n", line_index - 1)
            end
        end
        info = info .. "\n"
    end
    
    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Shuffle Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
end

return shuffles