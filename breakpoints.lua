-- breakpoints.lua
local breakpoints = {}
local vb = renoise.ViewBuilder()
local evaluators = require("evaluators")
local duplicator = require("duplicator")
local utils = require("utils")

    
local function calculate_set_distances(set, analysis)
    local set_timing = {}
    
    if #set.notes > 0 then
        local first_note = set.notes[1]
        local delay_adjustment = first_note.delay_value
        local base_line = first_note.line  -- Store first line as reference point
        
        -- Set up first note
        set_timing[1] = {
            original_line = first_note.line,
            relative_line = 1,  -- First note is always 0
            original_delay = first_note.delay_value,
            new_delay = 0,  -- First note always 0
            original_distance = first_note.distance,
            new_distance = first_note.distance + delay_adjustment,
            note_value = first_note.note_value,
            instrument_value = first_note.instrument_value
        }
        
        -- Process subsequent notes
        for i = 2, #set.notes do
            local current_note = set.notes[i]
            local new_line = current_note.line
            local new_delay = current_note.delay_value - delay_adjustment
            
            -- Handle negative delay by moving to previous line
            if new_delay < 0 then
                new_line = new_line - 1
                new_delay = 256 + new_delay
            end
            
            set_timing[i] = {
                original_line = current_note.line,
                relative_line = new_line + 1 - base_line,  -- Calculate relative to first note
                original_delay = current_note.delay_value,
                new_delay = new_delay,
                original_distance = current_note.distance,
                new_distance = current_note.distance + delay_adjustment,
                note_value = current_note.note_value,
                instrument_value = current_note.instrument_value
            }
        end
    end
    
    return set_timing
end

-- Calculate timing for transitioning between two sets
local function calculate_set_transition(from_set, to_set)
    if not from_set.timing or not to_set.timing or 
       #from_set.timing == 0 or #to_set.timing == 0 then
        return {
            lines_to_add = 0,
            delay_adjustment = 0
        }
    end
    
    -- Get last note of source set
    local last_note = from_set.timing[#from_set.timing]
    
    -- Get initial timing values
    local orig_distance = last_note.original_distance
    local lines_to_add = math.floor(orig_distance / 256)
    local delay_adjustment = orig_distance % 256
    
    print(string.format("Transition Calculation:"))
    print(string.format("  Original Distance: %d", orig_distance))
    print(string.format("  Lines to Add: %d", lines_to_add))
    print(string.format("  Delay Adjustment: %d", delay_adjustment))
    
    return {
        lines_to_add = lines_to_add,
        delay_adjustment = delay_adjustment,
        original_distance = orig_distance
    }
end

local function reset_set_timing(break_set, original_set)
    -- Reset timing array
    break_set.timing = {}
    
    -- Copy original timing values
    for i, timing in ipairs(original_set.timing) do
        break_set.timing[i] = {
            instrument_value = timing.instrument_value,
            original_distance = timing.original_distance,
            original_delay = timing.original_delay,
            new_distance = timing.original_distance, -- Reset to original
            new_delay = timing.original_delay,      -- Reset to original
            relative_line = timing.original_line,   -- Reset to original line
            original_line = timing.original_line
        }
    end
    
    return break_set
end


-- Gets all the breakpoint-tagged slices and their line positions
local function get_breakpoint_indices(saved_labels)
    local breakpoint_indices = {}
    local count = 0  -- Add explicit counter
    print("\nSearching for breakpoint-tagged slices...")
    
    -- Get actual count of saved labels
    local label_count = 0
    for _ in pairs(saved_labels) do
        label_count = label_count + 1
    end
    print("Saved labels structure:", label_count)
    
    for hex_key, label_data in pairs(saved_labels) do
        print(string.format("Checking slice %s - Breakpoint: %s", 
            hex_key, tostring(label_data.breakpoint)))
        if label_data.breakpoint then
            local index = tonumber(hex_key, 16) - 1
            breakpoint_indices[index] = true
            count = count + 1  -- Increment counter
            print("Found breakpoint at index:", index)
        end
    end
    
    -- Print actual count instead of using #
    print("Total breakpoints found:", count)
    
    -- Debug: Print all found breakpoint indices
    print("\nBreakpoint indices found:")
    for index, _ in pairs(breakpoint_indices) do
        print("Index:", index)
    end
    
    return breakpoint_indices
end

-- Find line numbers where breakpoint-tagged slices occur
local function get_breakpoint_lines(phrase, breakpoint_indices)
    local breakpoint_lines = {}
    for i = 1, phrase.number_of_lines do
        local line = phrase:line(i)
        local note_column = line:note_column(1)
        if note_column.note_value ~= 121 and -- Not empty
           breakpoint_indices[note_column.instrument_value] then
            table.insert(breakpoint_lines, i)
        end
    end
    table.sort(breakpoint_lines)
    return breakpoint_lines
end

function breakpoints.create_break_patterns(instrument, original_phrase, saved_labels)
    local sets = {}
    local analysis = evaluators.get_line_analysis(original_phrase)
    local breakpoint_indices = get_breakpoint_indices(saved_labels)
    local breakpoint_lines = get_breakpoint_lines(original_phrase, breakpoint_indices)
    
    -- Find start and end points for each set
    local set_boundaries = {}
    table.insert(set_boundaries, 1)
    for _, line in ipairs(breakpoint_lines) do
        table.insert(set_boundaries, line)
    end
    table.insert(set_boundaries, original_phrase.number_of_lines + 1)
    
    -- Create sets from boundaries
    for i = 1, #set_boundaries - 1 do
        local set = {
            start_line = set_boundaries[i],
            end_line = set_boundaries[i + 1] - 1,
            notes = {}
        }
        
        -- Collect notes within this set's boundaries
        for line = set.start_line, set.end_line do
            if analysis[line] and analysis[line].note_value ~= renoise.PatternLine.EMPTY_NOTE then
                table.insert(set.notes, {
                    line = line,
                    note_value = analysis[line].note_value,
                    instrument_value = analysis[line].instrument_value,
                    delay_value = analysis[line].delay_value,
                    distance = analysis[line].distance,
                    is_last = analysis[line].is_last
                })
            end
        end
        
        -- Calculate new timing for the set
        set.timing = calculate_set_distances(set, analysis)
        
        table.insert(sets, set)
    end
    
    -- Debug output
    print("\nBreakpoint Sets Analysis:")
    print(string.format("Total Sets: %d", #sets))
    print(string.rep("-", 70))
    
    for i, set in ipairs(sets) do
        print(string.format("\nSet %d:", i))
        print(string.format("Lines: %d to %d", set.start_line, set.end_line))
        print(string.format("Notes in set: %d", #set.notes))
        
        if set.timing and #set.timing > 0 then
            print("\nTiming Details:")
            print(string.format("%-6s %-6s %-8s %-8s %-12s %-12s %-8s",
                "OrgLn", "RelLn", "OrgDly", "NewDly", "OrgDist", "NewDist", "InstVal"))
            print(string.rep("-", 70))
            
            for _, timing in ipairs(set.timing) do
                print(string.format("%-6d %-6d %-8d %-8d %-12d %-12d %-8d",
                    timing.original_line,
                    timing.relative_line,  -- Fixed to match our new structure
                    timing.original_delay,
                    timing.new_delay,
                    timing.original_distance,
                    timing.new_distance,
                    timing.instrument_value
                ))
            end
        end
    end
    print(string.rep("-", 70))
    
    return sets, instrument
end

function adjust_timing(set, adjusted_delay, next_start_line)
    local adjusted_set = set
    for _, timing in ipairs(adjusted_set.timing) do
        timing.new_delay = timing.new_delay + adjusted_delay
        if timing.new_delay > 255 then
            timing.new_delay = timing.new_delay % 256
            timing.relative_line = timing.relative_line + 1
        end
    end

    for _, timing in ipairs(adjusted_set.timing) do
        timing.relative_line = timing.relative_line + next_start_line
    end

    return adjusted_set
end

function generate_permutations(n)
    local result = {}
    local a = {}
    
    for i = 1, n do
      a[i] = i
    end
    
    local function permute(k)
      if k == n then
        local perm = {}
        for i = 1, n do
          perm[i] = a[i]
        end
        result[#result + 1] = perm
      else
        for i = k, n do
          a[k], a[i] = a[i], a[k]
          permute(k + 1)
          a[k], a[i] = a[i], a[k]
        end
      end
    end
    
    permute(1)
    return result
end

function create_permutation_phrase(perm, perm_name, original_phrase)
    local song = renoise.song()
    local current_instrument = renoise.song().selected_instrument
    local new_phrase = duplicator.duplicate_phrases(current_instrument, original_phrase, 1)[1]

    -- Convert numeric permutation name into letters (e.g. "1-2-3" becomes "A-B-C")
    local letter_name = perm_name:gsub("%d", function(d)
        return string.char(string.byte('A') + tonumber(d) - 1)
    end)
    
    new_phrase.name = string.format("Break Perm %s", letter_name)
        
    -- Clear and prepare phrase
    utils.clear_phrase(new_phrase)

    for _, timing in ipairs(perm.timing) do
        local line = new_phrase:line(timing.relative_line)
        local note_column = line:note_column(1)
            
        note_column.note_value = 48  -- C-4
        note_column.instrument_value = timing.instrument_value
        note_column.delay_value = timing.new_delay
    end
end


function stitch_breaks(perm, sets, setA, setB, first_set)
    print("PERMUTATION")
    print(table.concat(perm, "  "))

    local new_set = {timing = {}} 

    if first_set then

        local setA_delay = setA.timing[#setA.timing].original_delay
        local setA_last_line = setA.timing[#setA.timing].relative_line
        local delay_diff = 256 - setA_delay
        local setA_distance = setA.timing[#setA.timing].original_distance
        
        local line_gap = math.floor((setA_distance - delay_diff) / 256)
        local adjusted_delay = setA_distance - delay_diff - (line_gap * 256)
        local next_start_line = setA_last_line + line_gap

        print("DELAY DIFF")
        print(delay_diff)
        print("DISTANCE")
        print(setA_distance)
        print("LINE GAP")
        print(line_gap)
        print("NEW DELAY")
        print(adjusted_delay)
        print("SET B STARTING LINE")
        print(next_start_line)
    
        local setB_adjusted = adjust_timing(setB, adjusted_delay, next_start_line)

        
        local line_count  = #setA.timing + #setB_adjusted.timing


        
        -- First, add all entries from setA
        for j, timing in ipairs(setA.timing) do
            new_set.timing[#new_set.timing + 1] = {
                instrument_value = timing.instrument_value,
                original_distance = timing.original_distance,
                original_delay = timing.original_delay,
                new_distance = timing.new_distance,
                new_delay = timing.new_delay,
                relative_line = timing.relative_line,
                original_line = timing.original_line
            }
        end
        
        -- Then, add all entries from setB
        for j, timing in ipairs(setB_adjusted.timing) do
            new_set.timing[#new_set.timing + 1] = {
                instrument_value = timing.instrument_value,
                original_distance = timing.original_distance,
                original_delay = timing.original_delay,
                new_distance = timing.new_distance,
                new_delay = timing.new_delay,
                relative_line = timing.relative_line,
                original_line = timing.original_line
            }
        end

        return new_set
    end

    if not first_set then
        local setA_delay = setA.timing[#setA.timing].new_delay
        local setA_last_line = setA.timing[#setA.timing].relative_line
        local delay_diff = 256 - setA_delay
        local setA_distance = setA.timing[#setA.timing].original_distance
        local line_gap = math.floor((setA_distance - delay_diff)/256)
        local adjusted_delay = setA_distance - delay_diff - (line_gap * 256)
        local next_start_line = setA_last_line + line_gap

        print("DELAY DIFF")
        print(delay_diff)
        print("DISTANCE")
        print(setA_distance)
        print("LINE GAP")
        print(line_gap)
        print("NEW DELAY")
        print(adjusted_delay)
        print("SET B STARTING LINE")
        print(next_start_line)
    
        local setB_adjusted = adjust_timing(setB, adjusted_delay, next_start_line)

        
        local line_count  = #setA.timing + #setB_adjusted.timing

        -- First, add all entries from setA
        for j, timing in ipairs(setA.timing) do
            new_set.timing[#new_set.timing + 1] = {
                instrument_value = timing.instrument_value,
                original_distance = timing.original_distance,
                original_delay = timing.original_delay,
                new_distance = timing.new_distance,
                new_delay = timing.new_delay,
                relative_line = timing.relative_line,
                original_line = timing.original_line
            }
        end
        
        -- Then, add all entries from setB
        for j, timing in ipairs(setB_adjusted.timing) do
            new_set.timing[#new_set.timing + 1] = {
                instrument_value = timing.instrument_value,
                original_distance = timing.original_distance,
                original_delay = timing.original_delay,
                new_distance = timing.new_distance,
                new_delay = timing.new_delay,
                relative_line = timing.relative_line,
                original_line = timing.original_line
            }
        end

        return new_set
    end
    print("Something went wrong!")
    return
end

function breakpoints.sort_breaks(sets, original_phrase, is_string, string_permutation)
    local set_count = #sets

    --    local function get_fresh_set(set_index)
    --      return duplicator.deep_copy(original_sets[set_index])
    --    end

    print("SET COUNT")
    print(set_count)

    local permutations = {}

    local used_sets = {}
    
    if is_string then
        if not string_permutation then
            print("Error: No string permutation provided")
            return
        end
        -- Create a single-element array containing the string permutation
        permutations = {string_permutation}
        print("Using string permutation:")
        print(table.concat(string_permutation, "-"))
    else
        permutations = generate_permutations(set_count)
    end


    local function printTable(t, indent)
        indent = indent or ""
        for k, v in pairs(t) do
          if type(v) == "table" then
            print(indent .. tostring(k) .. ":")
            printTable(v, indent .. "  ")
          else
            print(indent .. tostring(k) .. ": " .. tostring(v))
          end
        end
    end
    
    print("PERMUTATIONS")
    print(#permutations)
    for _, perm in ipairs(permutations) do
        local new_set = {timing = {}}
        local process_success = true
        
        print("Processing permutation:", table.concat(perm, "  "))
        
        for i, set_index in ipairs(perm) do
            if not process_success then
                break
            end
            
            print(string.format("Processing set %d at position %d", set_index, i))
            
            -- Create a fresh copy of the set regardless of whether it's been used before
            local current_set = duplicator.deep_copy(sets[set_index])
            
            if i == 1 then
                -- For first stitch, make fresh copy of next set too
                local next_set = duplicator.deep_copy(sets[perm[2]])
                print("Processing first set")
                new_set = stitch_breaks(perm, sets, current_set, next_set, true)
                
                if not new_set then
                    print("Error: stitch_breaks failed for first set")
                    process_success = false
                    break
                end
                printTable(new_set)
                
            elseif i < #perm then
                print("Processing intermediate set")
                local starting_set = new_set
                -- Get fresh copy of next set
                local next_set = duplicator.deep_copy(sets[perm[i + 1]])
                new_set = stitch_breaks(perm, sets, starting_set, next_set, false)
                
                if not new_set then
                    print("Error: stitch_breaks failed for intermediate set")
                    process_success = false
                    break
                end
                printTable(new_set)
                
            elseif i == #perm then
                print("Processing final set")
                local perm_name = table.concat(perm, "-")
                create_permutation_phrase(new_set, perm_name, original_phrase)
            end
        end
    end
end

function breakpoints.show_results(new_phrases, new_instrument)
    -- This function will be implemented when we start handling the actual pattern generation
end

return breakpoints