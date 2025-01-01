-- main.lua
local vb = renoise.ViewBuilder()
local duplicator = require("duplicator")
local modifiers = require("modifiers")
local evaluators = require("evaluators")
local labeler = require("labeler")
local rollers = require("rollers") 
local shuffles = require("shuffles")
local extras = require("extras")
local multis = require("multis")
local beats = require("beats")
local euclideans = require("euclideans")
local syntax = require("syntax")
local breakpoints = require("breakpoints")

local dialog = nil  -- Rename from dialog to main_dialog for clarity


local function reopen_main_dialog()
    if not dialog or not dialog.visible then
        show_dialog()
    end
end


local function copy_and_modify_phrases(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local first_phrase = phrases[1]
  
  local new_phrases = duplicator.duplicate_phrases(instrument, first_phrase, 15)
  
  modifiers.modify_phrase_by_halves(new_phrases[15], 1, 2)
  modifiers.modify_phrase_by_halves(new_phrases[14], 2, 3)
  modifiers.modify_phrase_by_halves(new_phrases[13], 3, 4)
  modifiers.modify_phrase_by_section(new_phrases[12], 1, 4)
  modifiers.modify_phrase_by_section(new_phrases[11], 2, 4)
  modifiers.modify_phrase_by_section(new_phrases[10], 3, 4)
  modifiers.modify_phrase_by_section(new_phrases[9], 4, 4)
  modifiers.modify_phrase_by_section(new_phrases[8], 1, 8)
  modifiers.modify_phrase_by_section(new_phrases[7], 2, 8)
  modifiers.modify_phrase_by_section(new_phrases[6], 3, 8)
  modifiers.modify_phrase_by_section(new_phrases[5], 4, 8)
  modifiers.modify_phrase_by_section(new_phrases[4], 5, 8)
  modifiers.modify_phrase_by_section(new_phrases[3], 6, 8)
  modifiers.modify_phrase_by_section(new_phrases[2], 7, 8)
  modifiers.modify_phrase_by_section(new_phrases[1], 8, 8)
  
  renoise.app():show_status("Phrases copied and modified successfully.")

  return first_phrase, new_phrases[1]
end

local function evaluate_phrase(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
      renoise.app():show_warning("No phrases found in the selected instrument.")
      return
  end
  
  local first_phrase = phrases[1]
  --evaluators.evaluate_note_length(first_phrase)
  evaluators.get_line_analysis(first_phrase)
end

local function create_break_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]
  local new_phrases, new_instrument = breakpoints.create_break_patterns(instrument, original_phrase, labeler.saved_labels)
  
  if #new_phrases > 0 then
    breakpoints.show_results(new_phrases, new_instrument)
    breakpoints.sort_breaks(new_phrases, original_phrase, false)
    renoise.app():show_status("Break patterns created successfully.")
  end
end

local function create_euclidean_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]
  local new_phrases, created_instruments = euclideans.create_euclidean_patterns(
    instrument, 
    original_phrase, 
    labeler.saved_labels
  )
  
  euclideans.show_results(new_phrases, created_instruments)
  
  renoise.app():show_status("Euclidean patterns created successfully.")
end

local function modify_phrases_with_labels(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 15 then
    renoise.app():show_warning("Not enough phrases found in the selected instrument. At least 15 phrases are required.")
    return
  end
  
  local original_phrase = phrases[1]
  
  for i = 15, 2, -1 do
    local copied_phrase = phrases[i]
    
    modifiers.modify_phrases_by_labels(copied_phrase, original_phrase, labeler.saved_labels)
    
    renoise.app():show_status(string.format("Phrase %d modified based on labels.", i))
  end
  
  renoise.app():show_status("All phrases modified based on labels successfully.")
end

local function create_roller_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]

  local new_phrases = rollers.create_alternating_patterns(instrument, original_phrase, labeler.saved_labels)

  rollers.show_results(new_phrases)

  
  renoise.app():show_status("Roller patterns created successfully.")
end

local function create_shuffle_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]

  local new_phrases = shuffles.create_shuffles(instrument, original_phrase, labeler.saved_labels)
  
  
  renoise.app():show_status("Shuffle patterns created successfully.")
end

local function create_extras_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]
  local label = "Multi-Sample Rolls"
  local new_instrument = duplicator.duplicate_instrument(label, 0)
  local new_phrases, new_instruments = multis.create_multi_patterns(new_instrument, original_phrase, labeler.saved_labels)
  local new_phrases = extras.create_pattern_variations(new_instrument, original_phrase, labeler.saved_labels)
  
  renoise.app():show_status("Extra patterns created successfully.")
end

local function create_beat_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index  + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]
  local label = "Beats"
  local new_instrument = duplicator.duplicate_instrument(label, 0)
  local new_phrases, new_instruments = beats.create_beat_patterns(new_instrument, original_phrase, labeler.saved_labels)
  
  renoise.app():show_status("Beat patterns created successfully.")

end

local function update_lock_state(dialog_vb)
  local song = renoise.song()
  local instrument_selector = dialog_vb.views.instrument_index
  local lock_button = dialog_vb.views.lock_button
  
  if instrument_selector and lock_button then
      instrument_selector.active = not labeler.is_locked
      lock_button.text = labeler.is_locked and "[-]" or "[O]"
      
      if not labeler.is_locked then
          local new_index = song.selected_instrument_index - 1
          if new_index > instrument_selector.max then
              new_index = instrument_selector.max
          elseif new_index < instrument_selector.min then
              new_index = instrument_selector.min
          end
          instrument_selector.value = new_index
      end
  end
end




function rollers.show_alternating_patterns_dialog(phrases)
    local vb = renoise.ViewBuilder()
    
    local phrase_info = {}
    for i, phrase in ipairs(phrases) do
        table.insert(phrase_info, {
            index = i,
            name = phrase.name
        })
    end
    
    local dialog_content = vb:column {
        margin = 10,
        spacing = 5,
        vb:text {
            text = "Alternating Patterns Phrases"
        },
        vb:row {
            vb:text {
                text = "Index",
                width = 50
            },
            vb:text {
                text = "Phrase Name",
                width = 250
            }
        }
    }
    
    for _, info in ipairs(phrase_info) do
        dialog_content:add_child(
            vb:row {
                vb:text {
                    text = tostring(info.index),
                    width = 50
                },
                vb:text {
                    text = info.name,
                    width = 250
                }
            }
        )
    end
    
    renoise.app():show_custom_dialog("Alternating Patterns Phrases", dialog_content)
end



local function create_symbol_row(vb, symbol, labels)
  -- Only create the column if we have labels
  if not labels or #labels == 0 then
      return nil
  end

  local note_rows = vb:column {
      width = "100%",
      margin = 10,
      style = "panel",
  }

  -- Add symbol header
  note_rows:add_child(
      vb:horizontal_aligner {
          mode = "center",
          vb:text {
              text = symbol,
              font = "big",
              align = "center"
          }
      }
  )

  -- Add each note in the set with spacing between notes
  for i, label_text in ipairs(labels) do
      note_rows:add_child(vb:row {
          vb:text {
              text = label_text,
              font = "mono",
              align = "left",
              width = "100%"
          }
      })
      
      -- Add space between notes except after the last one
      if i < #labels then
          note_rows:add_child(vb:space { height = 2 })
      end
  end

  return note_rows
end

local function add_symbol_row(vb, symbol)
  local composite_symbols = vb.views.composite_symbols
  local new_row = vb:row {
      margin = 5,
      vb:text {
          text = symbol .. " =",
          width = 25
      },
      vb:textfield {
          id = "symbol_" .. string.lower(symbol),
          width = 465,
          height = 25
      }
  }
  composite_symbols:add_child(new_row)
end

local function update_add_button(vb, current_symbol_index, symbols)
  local add_button = vb.views.add_button
  if add_button then
      add_button.visible = current_symbol_index < #symbols
  end
end


local function create_symbol_editor_dialog()
  local vb = renoise.ViewBuilder()
  local symbols = {"U", "V", "W", "X", "Y", "Z"}
  local current_symbol_index = 0

  -- Get current break sets
  local song = renoise.song()
  local instrument = song.selected_instrument
  local saved_labels = labeler.saved_labels
  local break_sets, original_phrase

  -- Only proceed with formatting if we have phrases
  local formatted_labels = {}
  if #instrument.phrases > 0 then
      original_phrase = instrument.phrases[1]
      break_sets = breakpoints.create_break_patterns(instrument, original_phrase, saved_labels)
      formatted_labels = syntax.prepare_symbol_labels(break_sets, saved_labels)
  end

  local function commit_to_phrase(dialog_vb)
      local break_string = dialog_vb.views.break_string.text
      
      if not break_sets then
          renoise.app():show_warning("No break sets available")
          return
      end
      
      local permutation, error = syntax.parse_break_string(break_string, #break_sets)
      if not permutation then
          renoise.app():show_warning("Invalid break string: " .. error)
          return
      end
      
      -- Use existing break_sets and original_phrase
      breakpoints.sort_breaks(break_sets, original_phrase, true, permutation)
      
      renoise.app():show_status("Break pattern created from string: " .. break_string)
  end
  -- Create array of valid symbol columns before building the UI
  local valid_symbol_columns = {}
  for _, symbol in ipairs({"A", "B", "C", "D", "E"}) do
      local symbol_col = create_symbol_row(vb, symbol, formatted_labels[symbol])
      if symbol_col then
          table.insert(valid_symbol_columns, symbol_col)
      end
  end

  local symbol_editor_content = vb:column {
      vb:column {
          width = 500,
          vb:row {
              vb:text {
                  text = "Symbols",
                  font = "big",
              }
          },
          vb:space { height = 10 },
          vb:horizontal_aligner {
              mode = "distribute",
              width = "100%",
              vb:row {
                  id = "symbols",
                  spacing = 5,
                  unpack(valid_symbol_columns)
              }
          }
      },
      
      vb:space { height = 10 },

      margin = 25,
      spacing = 5,
      
      vb:column {
          margin =5,
          style = "group",
          vb:text {
              text = "Break String",
              font = "big",
          },
          vb:space { height = 10 },
          vb:textfield {
              id = "break_string",
              width = 490,
              height = 25
          }
      },
      
      vb:space { height = 10 },
      
      vb:column {
          vb:text {
              text = "Composite Symbols",
              font = "big",
          },
          vb:space { height = 10 },
          vb:column {
              id = "composite_symbols",
              style = "group"
          },
          vb:button {
            id = "add_button",
            text = "+",
            width = 25,
            height = 25,
            notifier = function()
                if current_symbol_index < #symbols then
                    current_symbol_index = current_symbol_index + 1
                    add_symbol_row(vb, symbols[current_symbol_index])
                    update_add_button(vb, current_symbol_index, symbols)
                end
                
                if current_symbol_index > #symbols then
                    renoise.app():show_status("You've reached the maximum number of Composite Symbols!")
                end
            end
        }
      },
      
      vb:space { height = 10 },
      
      vb:horizontal_aligner {
        mode = "distribute",
        vb:column {
          vb:button {
              text = "Import Syntax",
              width = 80,
              height = 20,
              notifier = function()
                  commit_to_phrase(vb)
              end
          },
        },
        vb:column {
          vb:button {
              text = "Export Syntax",
              width = 80,
              height = 20,
              notifier = function()
                local break_string = vb.views.break_string.text
                local composite_symbols = {}
                
                -- Collect composite symbol values
                for _, symbol in ipairs(symbols) do
                  local symbol_view = vb.views["composite_" .. symbol]
                  if symbol_view then
                    composite_symbols[symbol] = symbol_view.text
                  end
                end
                
                -- Show file dialog to choose save location
                local filepath = renoise.app():prompt_for_filename_to_write("csv", "Export Syntax")
                
                if filepath then
                  if not filepath:lower():match("%.csv$") then
                    filepath = filepath .. ".csv"
                  end
                  syntax.export_to_csv(break_string, composite_symbols, filepath)
                end
              end
            },
        },
      },

      vb:space { height = 10 },
      
      vb:horizontal_aligner {
          mode = "justify",
          vb:column {
              vb:button {
                  text = "Commit to Phrase",
                  width = 150,
                  height = 30,
                  notifier = function()
                      commit_to_phrase(vb)
                  end
              },
          },
          vb:column {
              vb:button {
                  text = "Commit to Pattern",
                  width = 150,
                  height = 30,
                  notifier = function()
                      commit_to_pattern(vb)
                  end
              },
          
          
          vb:space { height = 10 },
          
          vb:row {
              vb:text {
                  text = "Starting Pattern"
              },
              vb:valuebox {
                  id = "pattern_number",
                  min = 0,
                  max = 999,
                  value = 0
              }
          }
          }
      }
  }
  
  return symbol_editor_content
end






local function show_dialog()
  if dialog and dialog.visible then
      dialog:close()
      dialog = nil
  end
  
  local song = renoise.song()
  local instrument_count = #song.instruments
  local dialog_vb = renoise.ViewBuilder()
  if instrument_count < 1 then
    renoise.app():show_warning("No instruments found in the song.")
    return
  end

  labeler.lock_state_observable:add_notifier(function()
    if dialog and dialog.visible then
        local song = renoise.song()
        update_lock_state(dialog_vb)
    end
  end)

  local function update_lock_state(dialog_vb)
    local song = renoise.song()
    local instrument_selector = dialog_vb.views.instrument_index
    local lock_button = dialog_vb.views.lock_button
    
    if instrument_selector and lock_button then
        instrument_selector.active = not labeler.is_locked
        lock_button.text = labeler.is_locked and "[-]" or "[O]"
        
        if not labeler.is_locked then
            local new_index = song.selected_instrument_index
            if new_index > instrument_selector.max + 1 then
                new_index = instrument_selector.max + 1
            elseif new_index < instrument_selector.min + 1 then
                new_index = instrument_selector.min + 1
            end
            instrument_selector.value = new_index - 1  -- Convert to 0-based for display
        end
    end
  end

  local function get_current_instrument_index()
    return labeler.locked_instrument_index or song.selected_instrument_index
  end

  local function has_valid_labels()
    if not labeler or not labeler.saved_labels then return false end
    
    for _, label_data in pairs(labeler.saved_labels) do
      if label_data.label and label_data.label ~= "---------" then
        return true
      end
    end
    return false
  end
  
  local function update_button_state()
    local song = renoise.song()
    local selected_instrument = song.instruments[song.selected_instrument_index]
    local has_samples = #selected_instrument.samples > 0
    local has_phrases = #selected_instrument.phrases > 0
    local can_label = has_samples and has_phrases
    local can_export = has_samples and has_valid_labels()

    local label_button = dialog_vb.views.label_button
    local evaluate_button = dialog_vb.views.evaluate_button
    local export_button = dialog_vb.views.export_button

    label_button.active = has_samples
    label_button.color = has_samples and {0,0,0} or {0.5,0.5,0.5}
    label_button.tooltip = has_samples and "Label and tag slices to assist phrase generation" or "Please load a sample first"

    evaluate_button.active = can_label
    evaluate_button.color = can_label and {0,0,0} or {0.5,0.5,0.5}
    evaluate_button.tooltip = can_label and "Review phrase notes and distances to each other" or 
        (not has_samples and "Please load a sample first" or "Please create at least one phrase")

    export_button.active = can_export
    export_button.color = can_export and {0,0,0} or {0.5,0.5,0.5}
    export_button.tooltip = can_export and "Export current slice labels" or
        (not has_samples and "Please load a sample first" or "No valid labels to export")
  end

  local function add_instrument_observers()
    local selected_instrument = song.instruments[get_current_instrument_index()]
    
    selected_instrument.samples_observable:add_notifier(function()
        update_button_state()
    end)
    
    selected_instrument.phrases_observable:add_notifier(function()
        update_button_state()
    end)
  end
  labeler.saved_labels_observable:add_notifier(function()
    update_button_state()
  end)


  add_instrument_observers()

  local dialog_content = dialog_vb:column {
    margin = 10,
    dialog_vb:row {
        dialog_vb:text {
            text = "Instrument Index:",
            font = "big",
            style = "strong"
        },
        dialog_vb:valuebox {
          id = 'instrument_index',
          min = 0,
          max = instrument_count - 1,
          value = (labeler.locked_instrument_index or song.selected_instrument_index) - 1,
          active = not labeler.is_locked,
          tostring = function(value) 
              return string.format("%02X", value)
          end,
          tonumber = function(str)
              return tonumber(str, 16)
          end,
          notifier = function(value)
              if not labeler.is_locked then
                  song.selected_instrument_index = value + 1  -- Ensure 1-based index for Renoise
                  add_instrument_observers()
                  update_button_state()
              end
          end
        },
        dialog_vb:button {
          id = 'lock_button',
          text = labeler.is_locked and "[-]" or "[O]",
          notifier = function()
            labeler.is_locked = not labeler.is_locked
            if labeler.is_locked then
                labeler.locked_instrument_index = song.selected_instrument_index
            else
                labeler.locked_instrument_index = nil
                local instrument_selector = dialog_vb.views.instrument_index
                if instrument_selector then
                    local new_index = song.selected_instrument_index - 1
                    if new_index <= instrument_selector.max and new_index >= instrument_selector.min then
                        instrument_selector.value = new_index
                    end
                end
            end
            labeler.lock_state_observable.value = not labeler.lock_state_observable.value
            update_lock_state(dialog_vb)
          end
        },
      dialog_vb:text {
        text = "Lock",
        font = "big",
        style = "strong"
      },
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:text {
        text = "Tag",
        font="big",
        style="strong"
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      spacing = 5,
      dialog_vb:button {
        id = "label_button",
        text = "Label Slices",
        notifier = function()
            if dialog and dialog.visible then
                dialog:close()
                dialog = nil
            end
            labeler.create_ui()
        end
      },
      dialog_vb:button {
        id = "recall_labels",
        text = "Recall Labels",
        notifier = function()
          labeler.recall_labels()
        end
      },
      dialog_vb:button {
        text = "Import Labels",
        notifier = function()
          labeler.import_labels()
          update_button_state()
        end
      },
      dialog_vb:button {
        id = "export_button",
        text = "Export Labels",
        notifier = function()
          labeler.export_labels()
        end
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:text {
        text = "Generate",
        font="big",
        style="strong"
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      spacing = 5,
      dialog_vb:button {
        text = "Make Breaks",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_break_patterns(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Create Phrases by Division",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          copy_and_modify_phrases(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Modify Phrases with Labels",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          modify_phrases_with_labels(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Make Rolls",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_roller_patterns(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Make Shuffles",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_shuffle_patterns(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Make Complex Rolls",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_extras_patterns(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Make Eukes",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_euclidean_patterns(instrument_index)
        end
      },
      dialog_vb:button {
        text = "Make Beats",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_beat_patterns(instrument_index)
        end
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:text {
        text = "Build",
        font="big",
        style="strong"
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:button {
        text = "Symbol Editor",
        notifier = function()
          local symbol_editor_content = create_symbol_editor_dialog()
          if symbol_editor_content then
            renoise.app():show_custom_dialog("Symbol Editor", symbol_editor_content)
          else
            print("Error: Symbol editor content is nil")
          end
        end
      }       
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:text {
        text = "Inspect",
        font="big",
        style="strong"
      }
    },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      spacing = 5,
      dialog_vb:button {
        id = "evaluate_button",
        text = "Evaluate Phrase",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          evaluate_phrase(instrument_index + 1)
        end
      },
      dialog_vb:button {
        text = "Show Phrases",
        notifier = function()
          local song = renoise.song()
          local current_instrument = song.selected_instrument
          if #current_instrument.phrases > 0 then
            local info = "Modified Phrases:\n\n"
            for i, phrase in ipairs(current_instrument.phrases) do
              info = info .. string.format("Phrase %02X: %s\n", i, phrase.name)
              info = info .. string.format("  Lines: %d, LPB: %d\n\n", 
                phrase.number_of_lines, phrase.lpb)
            end
            
            local dialog_content = vb:column {
              margin = 10,
              dialog_vb:text { text = "Phrase Results" },
              vb:multiline_textfield {
                text = info,
                width = 400,
                height = 300,
                font = "mono"
              }
            }
            
            renoise.app():show_custom_dialog("Phrase Results", dialog_content)
          else
            renoise.app():show_warning("No modified phrases found.")
          end
        end
      },

      
    }
  }



  song.selected_instrument_observable:add_notifier(function()
    if not labeler.is_locked and dialog and dialog.visible then
        local instrument_selector = dialog_vb.views.instrument_index
        if instrument_selector then
            local new_index = song.selected_instrument_index - 1
            if new_index <= instrument_selector.max and new_index >= instrument_selector.min then
                instrument_selector.value = new_index
            end
        end
    end
  end)

  update_button_state()  
  
  dialog = renoise.app():show_custom_dialog("BreakPal", dialog_content)
end

labeler.set_show_dialog_callback(show_dialog)

renoise.tool():add_menu_entry {
  name = "Main Menu:Tools:BreakPal...",
  invoke = function()
    show_dialog()
  end
}


function cleanup()
  if dialog and dialog.visible then
      dialog:close()
      dialog = nil
  end
  labeler.cleanup()
end
