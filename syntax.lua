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

-- Add this after the other helper functions but before parse_break_string
function syntax.resolve_break_string(break_string, composite_symbols)
    if not break_string or break_string == "" then
        return break_string, "Break string cannot be empty"
    end

    local result = ""
    for char in break_string:gmatch(".") do
        if composite_symbols and composite_symbols[char] and composite_symbols[char] ~= "" then
            -- Add composite symbol resolution
            result = result .. composite_symbols[char]
        else
            -- Keep original character if no composite symbol defined
            result = result .. char
        end
    end
    
    return result
end

-- Update the existing prepare_symbol_labels function to add validation
function syntax.validate_composite_symbol(symbol_str, valid_symbols)
    if not symbol_str or symbol_str == "" then
        return true  -- Empty strings are valid (they're ignored)
    end
    
    -- Check each character is a valid base symbol
    for char in symbol_str:gmatch(".") do
        if not valid_symbols[char] then
            return false
        end
    end
    
    return true
end

function syntax.parse_break_string(break_string, num_sets, composite_symbols)
    if not break_string or break_string == "" then
        return nil, "Break string cannot be empty"
    end

    local permutation = {}
    local valid_symbols = {}
    local symbol_list = {"A", "B", "C", "D", "E"}
    
    -- Build valid symbols map
    for i = 1, num_sets do
        valid_symbols[symbol_list[i]] = i
    end
    
    -- Clean input string
    break_string = break_string:upper():gsub("%s+", "")
    
    -- First validate composite symbols if present
    if composite_symbols then
        for symbol, value in pairs(composite_symbols) do
            if value and value ~= "" and not syntax.validate_composite_symbol(value, valid_symbols) then
                return nil, string.format("Invalid composite symbol '%s': value '%s' contains invalid base symbols", 
                    symbol, value)
            end
        end
    end
    
    -- Resolve composite symbols if present
    local resolved_string = syntax.resolve_break_string(break_string, composite_symbols)
    if not resolved_string then
        return nil, "Failed to resolve break string"
    end
    
    -- Process resolved string
    for i = 1, #resolved_string do
        local symbol = resolved_string:sub(i, i)
        local set_index = valid_symbols[symbol]
        
        if not set_index then
            local valid_chars = table.concat(symbol_list, ", ", 1, num_sets)
            return nil, string.format("Syntax violation: Invalid symbol '%s' found. Valid symbols are: %s", 
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