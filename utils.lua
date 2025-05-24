local utils = {}
local vb = renoise.ViewBuilder()

function utils.get_current_instrument()
    local song = renoise.song()
    if labeler and labeler.is_locked and labeler.locked_instrument_index then
        return song:instrument(labeler.locked_instrument_index)
    end
    return song.selected_instrument
end


function utils.generate_curve(curveType, start, endValue, intervals)
    local result = {}
    local range = endValue - start
    print("INTERVALS")
    print(intervals)
    
    for i = 0, intervals - 1 do
        local t = i / (intervals - 1)
        local value
        
        if curveType == "linear" then
            value = start + t * range
        elseif curveType == "logarithmic" then
            value = start + math.log(1 + t) / math.log(2) * range
        elseif curveType == "exponential" then
            value = start + (math.exp(t) - 1) / (math.exp(1) - 1) * range
        elseif curveType == "downParabola" then
            value = start + 4 * range * (t - 0.5)^2
        elseif curveType == "upParabola" then
            value = endValue - 4 * range * (t - 0.5)^2
        elseif curveType == "doublePeak" then
            -- Create two peaks at t=0.25 and t=0.75, valleys at t=0, t=0.5, t=1
            value = start + range * math.abs(math.sin(t * 2 * math.pi))
        elseif curveType == "doubleValley" then
            -- Create two valleys at t=0.25 and t=0.75, peaks at t=0, t=0.5, t=1  
            value = start + range * (1 - math.abs(math.sin(t * 2 * math.pi)))
        else
            error("Invalid curve type")
        end
        
        table.insert(result, math.floor(value + 0.5))
    end
    
    return result
end


function utils.augment_phrase(augmentation, phrase)
    local fx_column = 1
    local start_value = 0x10  -- Start at 16 (hexadecimal)
    local increment = 0x10    -- Increment by 16 (hexadecimal)

    if augmentation == "Upshift" or augmentation == "Downshift" then
        local flag = (augmentation == "Upshift" and "0U") or (augmentation == "Downshift" and "0D")
        local value = start_value
        local first_note_found = false
        for i = 1, phrase.number_of_lines do
            local line = phrase:line(i)
            if line.note_columns[1].note_value ~= renoise.PatternLine.EMPTY_NOTE then
                if first_note_found then
                    line.effect_columns[fx_column].number_string = flag
                    line.effect_columns[fx_column].amount_string = string.format("%02X", value)
                    value = value + increment
                    if value > 0xFF then value = 0xFF end  -- Cap at FF (255)
                else
                    first_note_found = true
                end
            end
        end
    elseif augmentation == "Staccato" then
        local i = 1
        while i <= phrase.number_of_lines do
            local line = phrase:line(i)
            if line.note_columns[1].note_value ~= renoise.PatternLine.EMPTY_NOTE then
                local next_line = phrase:line(i + 1)
                if next_line then
                    next_line.note_columns[1].note_string = "OFF"
                    i = i + 2  
                else
                    break  
                end
            else
                i = i + 1 
            end
        end
    elseif augmentation == "Backwards" then
        for i = 1, phrase.number_of_lines do
            local line = phrase:line(i)
            if line.note_columns[1].note_value ~= renoise.PatternLine.EMPTY_NOTE then
                line.effect_columns[fx_column].number_string = "0B"
                line.effect_columns[fx_column].amount_string = "00"
            end
        end
    elseif augmentation == "Reversal" then
        local reverse_flag = true
        for i = 1, phrase.number_of_lines do
            local line = phrase:line(i)
            if line.note_columns[1].note_value ~= renoise.PatternLine.EMPTY_NOTE then
                line.effect_columns[fx_column].number_string = "0B"
                line.effect_columns[fx_column].amount_string = reverse_flag and "00" or "01"
                reverse_flag = not reverse_flag
            end
        end
    end
end

function utils.multiply_phrase_length(phrase, length)
    if not phrase then
        print("Invalid phrase provided")
        return nil
    end

    local current_lines = phrase.number_of_lines
    local new_lines = current_lines * length

    print("Current lines: " .. current_lines)
    print("New lines: " .. new_lines)


    phrase.number_of_lines = new_lines
    print("Phrase resized to: " .. phrase.number_of_lines .. " lines")

    for i = current_lines + 1, new_lines do
        local source_line = phrase:line((i - 1) % current_lines + 1)
        local dest_line = phrase:line(i)
        dest_line:copy_from(source_line)
    end

    print("Content duplicated to fill new length")

    return phrase
end

function utils.clear_phrase(phrase)
    print(phrase)
    for _, line in ipairs(phrase.lines) do
        for _, note_column in ipairs(line.note_columns) do note_column:clear() end
        for _, effect_column in ipairs(line.effect_columns) do effect_column:clear() end
    end
end

function utils.get_slices_by_label(saved_labels, target_label)
    local slices = {roll = {}, ghost = {}, shuffle = {}}
    for hex_key, label_data in pairs(saved_labels) do
        if label_data.label == target_label then
            local index = tonumber(hex_key, 16) - 1
            if label_data.roll then
                table.insert(slices.roll, index)
            end
            if label_data.ghost_note then
                table.insert(slices.ghost, index)
            end
            if label_data.shuffle then 
                table.insert(slices.shuffle, index)
            end
        end
    end
    return slices
end

function utils.calculate_total_ticks(note1_line, note1_delay, note2_line, note2_delay)
    local line_diff = note2_line - note1_line
    return (line_diff * 256) - note1_delay + note2_delay
end

function utils.calculate_new_delay(prev_line, prev_delay, target_line, total_ticks)
    local line_diff = target_line - prev_line
    local new_delay = total_ticks - (line_diff * 256)
    
    -- Handle negative delay by moving to previous line
    if new_delay < 0 then
        return {
            line = target_line - 1,
            delay = 256 + new_delay
        }
    end
    
    return {
        line = target_line,
        delay = new_delay
    }
end

function utils.validate_note_timing(note_data)
    if note_data.delay_value >= 256 then
        local extra_lines = math.floor(note_data.delay_value / 256)
        note_data.line = note_data.line + extra_lines
        note_data.delay_value = note_data.delay_value % 256
    elseif note_data.delay_value < 0 then
        local lines_back = math.ceil(math.abs(note_data.delay_value) / 256)
        note_data.line = note_data.line - lines_back
        note_data.delay_value = 256 + (note_data.delay_value % 256)
    end
    return note_data
end

-- Global humanization settings
utils.humanize = {
    enabled = false,
    min = -4,
    max = 4
}

-- Global decay compensation settings
utils.decay_compensation = {
    enabled = false,
    curve_type = "exponential", -- "exponential", "logarithmic", "linear"
    offset = 0, -- lines to skip before applying decay
    min_volume = 0, -- minimum volume level (0-15)
    max_volume = 15 -- starting volume level (0-15)
}

function utils.humanize_phrase(phrase)
    if not phrase or not utils.humanize.enabled then return end
    
    local min_range = utils.humanize.min
    local max_range = utils.humanize.max
    local first_note_found = false
    
    for i = 1, phrase.number_of_lines do
        local line = phrase:line(i)
        
        -- Check all note columns (Renoise supports up to 12 note columns)
        for col = 1, 12 do
            local note_column = line:note_column(col)
            
            -- Check if this column has a note
            if note_column.note_value ~= renoise.PatternLine.EMPTY_NOTE then
                if first_note_found then
                    -- Apply humanization to all notes except the first
                    local current_delay = note_column.delay_value
                    
                    -- Adjust the random range to ensure result stays within 0-255
                    local actual_min = math.max(min_range, -current_delay)
                    local actual_max = math.min(max_range, 255 - current_delay)
                    
                    -- Only apply variation if there's a valid range
                    if actual_min <= actual_max then
                        local variation = math.random(actual_min, actual_max)
                        local new_delay = current_delay + variation
                        note_column.delay_value = new_delay
                    end
                else
                    -- Skip the first note found in the entire phrase
                    first_note_found = true
                end
            end
        end
    end
end

function utils.apply_decay_compensation(phrase)
    if not phrase or not utils.decay_compensation.enabled then return end
    
    local curve_type = utils.decay_compensation.curve_type
    local offset = utils.decay_compensation.offset
    local min_vol = utils.decay_compensation.min_volume
    local max_vol = utils.decay_compensation.max_volume
    
    -- Find all notes and their positions
    local notes = {}
    for i = 1, phrase.number_of_lines do
        local line = phrase:line(i)
        for col = 1, 12 do
            local note_column = line:note_column(col)
            if note_column.note_value ~= renoise.PatternLine.EMPTY_NOTE then
                table.insert(notes, {line = i, column = col})
            end
        end
    end
    
    -- Apply decay between each note
    for i = 1, #notes - 1 do
        local current_note = notes[i]
        local next_note = notes[i + 1]
        local start_line = current_note.line + offset + 1  -- Removed the +1
        local end_line = next_note.line - 1
        
        if start_line <= end_line then
            local distance = end_line - start_line + 1
            local decay_curve = utils.generate_decay_curve(curve_type, max_vol, min_vol, distance)
            
            -- Apply the decay curve
            for j = 1, distance do
                local target_line = start_line + j - 1
                if target_line <= phrase.number_of_lines then
                    local line = phrase:line(target_line)
                    local effect_column = line:effect_column(1)
                    
                    -- 0C effect with XY in amount_value
                    -- X=volume (0-F), Y=tick offset (0)
                    effect_column.number_string = "0C"
                    effect_column.amount_value = decay_curve[j] * 16  -- Convert to X0 format
                end
            end
        end
    end
    
    -- Handle the last note decay to end of phrase
    if #notes > 0 then
        local last_note = notes[#notes]
        local start_line = last_note.line + offset + 1  -- Removed the +1 here too
        local end_line = phrase.number_of_lines
        
        if start_line <= end_line then
            local distance = end_line - start_line + 1
            local decay_curve = utils.generate_decay_curve(curve_type, max_vol, min_vol, distance)
            
            for j = 1, distance do
                local target_line = start_line + j - 1
                if target_line <= phrase.number_of_lines then
                    local line = phrase:line(target_line)
                    local effect_column = line:effect_column(1)
                    effect_column.number_string = "0C"
                    effect_column.amount_value = decay_curve[j] * 16  -- Convert to X0 format
                end
            end
        end
    end
end

function utils.generate_decay_curve(curve_type, start_vol, end_vol, length)
    local curve = {}
    local range = start_vol - end_vol
    
    for i = 1, length do
        local t = (i - 1) / (length - 1)
        local value
        
        if curve_type == "linear" then
            value = start_vol - (t * range)
        elseif curve_type == "exponential" then
            -- Fast decay at start, slow at end
            value = end_vol + range * math.exp(-t * 3)
        elseif curve_type == "logarithmic" then
            -- Slow decay at start, fast at end
            value = start_vol - range * (math.log(1 + t * 9) / math.log(10))
        end
        
        -- Ensure value is within valid range and round to integer
        value = math.floor(math.max(0, math.min(15, value)) + 0.5)
        table.insert(curve, value)
    end
    
    return curve
end

return utils