-- euclideans.lua
local euclideans = {}
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local utils = require("utils")
local templates = require("templates")


local function rotate_pattern(pattern, n)
    if #pattern == 0 then return pattern end
    n = n % #pattern
    if n == 0 then return pattern end
    return pattern:sub(n + 1) .. pattern:sub(1, n)
end

local function get_shuffle_ghost_pairs(saved_labels, label)
    local shuffle_slices = {}
    local ghost_slices = {}
    
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == label then
            local index = tonumber(hex_key, 16) - 1
            if label_data.shuffle then
                table.insert(shuffle_slices, index)
            elseif label_data.ghost_note then
                table.insert(ghost_slices, index)
            end
        end
    end
    
    local pairs = {}
    if #shuffle_slices > 0 and #ghost_slices > 0 then
        for _, shuffle_index in ipairs(shuffle_slices) do
            for _, ghost_index in ipairs(ghost_slices) do
                table.insert(pairs, {
                    shuffle = shuffle_index,
                    ghost = ghost_index
                })
            end
        end
    end
    
    return pairs
end

local function create_instrument_for_label(base_instrument, label, index)
    local song = renoise.song()
    local new_instrument = duplicator.duplicate_instrument(
        string.format("%s-Eukes-%02d", label, index), 
        0
    )
    
    while #new_instrument.phrases > 0 do
        new_instrument:delete_phrase_at(1)
    end
    
    return new_instrument
end

local function sort_euclidean_templates()
    local sorted = {}
    for name, pattern in pairs(templates) do
        if name:match("^_%d+_%d+euclidean$") then
            table.insert(sorted, {name = name, pattern = pattern})
        end
    end
    
    table.sort(sorted, function(a, b)
        local a_first, a_second = a.name:match("_(%d+)_(%d+)euclidean")
        local b_first, b_second = b.name:match("_(%d+)_(%d+)euclidean")
        
        a_first, a_second = tonumber(a_first), tonumber(a_second)
        b_first, b_second = tonumber(b_first), tonumber(b_second)
        
        if a_first == b_first then
            return a_second < b_second
        end
        return a_first < b_first
    end)
    
    return sorted
end


local function apply_euclidean_pattern(phrase, pattern_str, pair)
    utils.clear_phrase(phrase)
    
    local line_multiplier = 4  
    local current_line = 1
    local use_shuffle = true  
    
    for i = 1, #pattern_str do
        local char = pattern_str:sub(i, i)
        if char == "x" then
            local note_column = phrase:line(current_line):note_column(1)
            note_column.note_value = 48  -- C-4
            note_column.instrument_value = use_shuffle and pair.shuffle or pair.ghost
            note_column.volume_value = use_shuffle and 128 or 64  -- Full volume for shuffle, half for ghost
            use_shuffle = not use_shuffle  -- Alternate between shuffle and ghost
            
            -- Clear the intermediate lines
            for j = 1, line_multiplier - 1 do
                if current_line + j <= phrase.number_of_lines then
                    phrase:line(current_line + j):note_column(1):clear()
                end
            end
        end
        current_line = current_line + line_multiplier
    end
end

local function create_timing_variation_instrument(base_instrument, original_instrument, suffix, lpb_multiplier)

    local new_instrument = create_instrument_for_label(base_instrument, 
        original_instrument.name:gsub("Eukes%-(%d+)$", "Eukes-%1" .. suffix), 0)
    

    for i = 1, #original_instrument.phrases do
        local new_phrase = new_instrument:insert_phrase_at(i)
        new_phrase:copy_from(original_instrument.phrases[i])
        new_phrase.lpb = math.floor(new_phrase.lpb * lpb_multiplier)
    end
    
    return new_instrument
end



local function create_base_euclidean_phrase(instrument, original_phrase, template_name, pattern_str, pair, rotation)
    local base_phrase = instrument:insert_phrase_at(#instrument.phrases + 1)
    base_phrase:copy_from(original_phrase)
    base_phrase.number_of_lines = #pattern_str * 4  
    

    local base_name = template_name:match("_(%d+_%d+)euclidean")
    base_phrase.name = string.format("Euke %s Rot %d", base_name, rotation)
    

    apply_euclidean_pattern(base_phrase, pattern_str, pair)
    
    -- Apply decay compensation after pattern application
    utils.apply_decay_compensation(base_phrase)
    
    return base_phrase
end

function euclideans.create_euclidean_patterns(instrument, original_phrase, saved_labels)
    local all_phrases = {}
    local instruments_created = {}
    local current_phrase_count = 0
    local instrument_index = 1
    

    local unique_labels = {}
    for _, label_data in pairs(saved_labels) do
        if not unique_labels[label_data.label] then
            unique_labels[label_data.label] = true
        end
    end
    
    for label in pairs(unique_labels) do
        local slice_pairs = get_shuffle_ghost_pairs(saved_labels, label)
        
        if #slice_pairs > 0 then
            local current_instrument = nil
            
            for _, pair in ipairs(slice_pairs) do
                local sorted_templates = sort_euclidean_templates()
                for _, template in ipairs(sorted_templates) do
                    local name, pattern = template.name, template.pattern
                    if current_phrase_count >= 120 or not current_instrument then
                        current_instrument = create_instrument_for_label(instrument, label, instrument_index)
                        instruments_created[label .. instrument_index] = current_instrument
                        instrument_index = instrument_index + 1
                        current_phrase_count = 0
                    end
                        
                    local pattern_str = pattern.x
                    for rotation = 0, pattern.shifts - 1 do
                        local rotated_pattern = rotate_pattern(pattern_str, rotation)
                        local base_phrase = create_base_euclidean_phrase(
                            current_instrument,
                            original_phrase,
                            name,
                            rotated_pattern,
                            pair,
                            rotation
                        )
                        utils.humanize_phrase(base_phrase)
                        table.insert(all_phrases, base_phrase)
                        current_phrase_count = current_phrase_count + 1
                        
                        if current_phrase_count >= 120 then
                            current_instrument = create_instrument_for_label(instrument, label, instrument_index)
                            instruments_created[label .. instrument_index] = current_instrument
                            instrument_index = instrument_index + 1
                            current_phrase_count = 0
                        end
                    end
                end
            end
        end
    end
    
    local original_instruments = {}
    for key, instr in pairs(instruments_created) do
        original_instruments[key] = instr
    end
    
    for key, orig_instr in pairs(original_instruments) do
        local half_instr = create_timing_variation_instrument(
            instrument, 
            orig_instr, 
            " - Half", 
            0.5
        )
        instruments_created[key .. "_half"] = half_instr
    end
    
    for key, orig_instr in pairs(original_instruments) do
        local double_instr = create_timing_variation_instrument(
            instrument, 
            orig_instr, 
            " - 2X", 
            2
        )
        instruments_created[key .. "_double"] = double_instr
    end
    
    return all_phrases, instruments_created
end

function euclideans.show_results(new_phrases, created_instruments)
    local info = "Created Euclidean Patterns:\n\n"
    
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
        info = info .. string.format("  Lines: %d\n\n", 
            phrase.number_of_lines)
    end
    
    local dialog_content = vb:column {
        margin = 10,
        vb:text { text = "Euclidean Patterns Created" },
        vb:multiline_textfield {
            text = info,
            width = 400,
            height = 300,
            font = "mono"
        }
    }
    
    renoise.app():show_custom_dialog("Euclidean Pattern Results", dialog_content)
end

return euclideans