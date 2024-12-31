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
    -- Format line number as 2 characters
    local line_str = string.format("%02d", note.line)
    
    -- Pad label to 5 characters with underscores
    local padded_label = pad_with_underscores(label or "", 5)
    
    -- Format delay value
    local delay_str = string.format("d%d", note.delay_value or 0)
    
    -- Combine all parts with hyphens
    return string.format("%s-%s-%s", line_str, padded_label, delay_str)
end

-- Prepare formatted labels for symbol editor using existing break sets
function syntax.prepare_symbol_labels(sets, saved_labels)
    local symbol_labels = {}
    local symbols = {"A", "B", "C", "D", "E"}
    
    for i = 1, math.min(#sets, #symbols) do
        local set = sets[i]
        if set and #set.notes > 0 then
            -- Get first note of the set
            local first_note = set.notes[1]
            -- Get label from saved_labels using instrument_value
            local hex_key = string.format("%02X", first_note.instrument_value + 1)
            local label = saved_labels[hex_key] and saved_labels[hex_key].label or "None"
            
            symbol_labels[symbols[i]] = syntax.format_break_label(first_note, label)
        end
    end
    
    return symbol_labels
end

return syntax