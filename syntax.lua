-- syntax.lua
local syntax = {}

-- Helper function to pad strings with underscores
local function pad_with_underscores(str, length)
    if #str >= length then
        return str:sub(1, length)
    end
    return str .. string.rep("_", length - #str)
end


local function escape_csv_field(field)
    if type(field) == "string" and (field:find(',') or field:find('"')) then
        -- Double quotes and wrap in quotes if field contains comma or quotes
        return '"' .. field:gsub('"', '""') .. '"'
    end
    return tostring(field)
end

local function unescape_csv_field(field)
    if field:sub(1,1) == '"' and field:sub(-1) == '"' then
        -- Remove surrounding quotes and convert double quotes back to single
        return field:sub(2, -2):gsub('""', '"')
    end
    return field
end

-- Add after escape functions
local function parse_csv_line(line)
    local fields = {}
    local field = ""
    local in_quotes = false
    
    local i = 1
    while i <= #line do
        local char = line:sub(i,i)
        
        if char == '"' then
            if in_quotes and line:sub(i+1,i+1) == '"' then
                field = field .. '"'
                i = i + 2
            else
                in_quotes = not in_quotes
                i = i + 1
            end
        elseif char == ',' and not in_quotes then
            table.insert(fields, field)
            field = ""
            i = i + 1
        else
            field = field .. char
            i = i + 1
        end
    end
    
    table.insert(fields, field)
    return fields
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

function syntax.export_syntax(dialog_vb)
    -- Get break string and composite symbols from dialog
    local break_string = dialog_vb.views.break_string.text
    local composite_symbols = {}
    local symbols = {"U", "V", "W", "X", "Y", "Z"}
    
    -- Collect composite symbol definitions
    for _, symbol in ipairs(symbols) do
        local view_id = "symbol_" .. string.lower(symbol)
        local symbol_view = dialog_vb.views[view_id]
        if symbol_view and symbol_view.text ~= "" then
            composite_symbols[symbol] = symbol_view.text
        end
    end

    -- Prompt for save location
    local filepath = renoise.app():prompt_for_filename_to_write("csv", "Export Break Syntax")
    if not filepath or filepath == "" then return end
    
    if not filepath:lower():match("%.csv$") then
        filepath = filepath .. ".csv"
    end
    
    -- Try to open file for writing
    local file, err = io.open(filepath, "w")
    if not file then
        renoise.app():show_error("Unable to open file for writing: " .. tostring(err))
        return
    end
    
    -- Write header
    file:write("Break String,U,V,W,X,Y,Z\n")
    
    -- Write data row
    local values = {
        break_string or "",
        composite_symbols["U"] or "",
        composite_symbols["V"] or "",
        composite_symbols["W"] or "",
        composite_symbols["X"] or "",
        composite_symbols["Y"] or "",
        composite_symbols["Z"] or ""
    }
    
    -- Escape each field
    for i, value in ipairs(values) do
        values[i] = escape_csv_field(value)
    end
    
    -- Write the row
    file:write(table.concat(values, ",") .. "\n")
    
    file:close()
    renoise.app():show_status("Break syntax exported to " .. filepath)
end


function syntax.import_syntax(dialog_vb)
    local filepath = renoise.app():prompt_for_filename_to_read({"*.csv"}, "Import Break Syntax")
    
    if not filepath or filepath == "" then return end
    
    local file, err = io.open(filepath, "r")
    if not file then
        renoise.app():show_error("Unable to open file: " .. tostring(err))
        return
    end
    
    -- Read and verify header
    local header = file:read()
    if not header or not header:lower():match("break string,u,v,w,x,y,z") then
        renoise.app():show_error("Invalid CSV format: Missing or incorrect header")
        file:close()
        return
    end

    -- Read the data line
    local data_line = file:read()
    if not data_line then
        renoise.app():show_error("No data found in file")
        file:close()
        return
    end

    -- Parse the CSV line
    local fields = parse_csv_line(data_line)
    if #fields ~= 7 then  -- Break string + 6 composite symbols
        renoise.app():show_error(string.format(
            "Invalid CSV format: Expected 7 fields, got %d", #fields))
        file:close()
        return
    end

    -- Update dialog views with imported data
    local break_string_view = dialog_vb.views.break_string
    if break_string_view then
        break_string_view.text = unescape_csv_field(fields[1])
    end

    -- Update composite symbol fields
    local symbols = {"U", "V", "W", "X", "Y", "Z"}
    for i, symbol in ipairs(symbols) do
        local view_id = "symbol_" .. string.lower(symbol)
        local symbol_view = dialog_vb.views[view_id]
        if symbol_view then
            symbol_view.text = unescape_csv_field(fields[i + 1]) -- +1 because break string is first
        end
    end

    file:close()
    renoise.app():show_status("Break syntax imported from " .. filepath)
end


return syntax