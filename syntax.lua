-- syntax.lua
local syntax = {}

-- Helper function to pad strings with underscores
local function pad_with_underscores(str, length)
    if #str >= length then
        return str:sub(1, length)
    end
    return str .. string.rep("_", length - #str)
end

-- Format a single break label according to the specification
function syntax.format_break_label(note, label)
    local line_str = string.format("%02d", note.line)
    local padded_label = pad_with_underscores(label or "", 5)
    local delay_str = string.format("d%02X", note.delay_value or 0)  -- Changed to hex with padding
    return string.format("%s-%s-%s", line_str, padded_label, delay_str)
end

function resolve_break_string(break_string, composite_symbols)
    local result = ""
    for char in break_string:gmatch(".") do
        if composite_symbols[char] then
            result = result .. composite_symbols[char]
        end
    end
    return result
end

function syntax.parse_break_string(break_string, num_sets)
    if not break_string or break_string == "" then
        return nil, "Break string cannot be empty"
    end

    local permutation = {}
    local valid_symbols = {}
    
    -- Dynamically build valid symbols based on number of sets
    local symbol_list = {"A", "B", "C", "D", "E"}
    for i = 1, num_sets do
        valid_symbols[symbol_list[i]] = i
    end
    
    -- Clean and validate string
    break_string = break_string:upper():gsub("%s+", "")
    
    -- Check each character
    for i = 1, #break_string do
        local symbol = break_string:sub(i, i)
        local set_index = valid_symbols[symbol]
        
        if not set_index then
            -- If num_sets is 3, show "Valid symbols are A, B, C"
            local valid_chars = table.concat(symbol_list, ", ", 1, num_sets)
            return nil, string.format(" Syntax violation: Invalid symbol '%s' found. Valid symbols are: %s", 
                symbol, valid_chars)
        end
        
        table.insert(permutation, set_index)
    end
    
    return permutation
end

-- Prepare formatted labels for symbol editor using existing break sets
function syntax.prepare_symbol_labels(sets, saved_labels)
    local symbol_labels = {}
    local symbols = {"A", "B", "C", "D", "E"}
    
    for i = 1, math.min(#sets, #symbols) do
        local set = sets[i]
        if set and #set.notes > 0 then
            symbol_labels[symbols[i]] = {}
            -- Process all notes in the set
            for _, note in ipairs(set.notes) do
                local hex_key = string.format("%02X", note.instrument_value + 1)
                local label = saved_labels[hex_key] and saved_labels[hex_key].label or "None"
                table.insert(symbol_labels[symbols[i]], syntax.format_break_label(note, label))
            end
        end
    end
    
    return symbol_labels
end



return syntax