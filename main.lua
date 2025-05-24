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
local offsets = require("offsets")
local utils = require('utils')
local settings = require("settings")

local dialog = nil  -- Rename from dialog to main_dialog for clarity
local advanced_enabled = false

-- Helper function for table operations
function table.merge(t1, t2)
    local result = {}
    for k, v in pairs(t1) do result[k] = v end
    for k, v in pairs(t2) do result[k] = v end
    return result
end

function table.find(t, value)
    for i, v in ipairs(t) do
        if v == value then return i end
    end
    return nil
end

-- Advanced menu creation functions
local function create_note_intervals_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Note Intervals",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_2",
                    value = settings.get("note_intervals", "enabled")[2] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled", 
                            table.merge(settings.get("note_intervals", "enabled"), {[2] = value}))
                    end
                },
                dialog_vb:text { text = "2" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_3",
                    value = settings.get("note_intervals", "enabled")[3] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[3] = value}))
                    end
                },
                dialog_vb:text { text = "3" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_4",
                    value = settings.get("note_intervals", "enabled")[4] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[4] = value}))
                    end
                },
                dialog_vb:text { text = "4" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_6",
                    value = settings.get("note_intervals", "enabled")[6] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[6] = value}))
                    end
                },
                dialog_vb:text { text = "6" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_8",
                    value = settings.get("note_intervals", "enabled")[8] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[8] = value}))
                    end
                },
                dialog_vb:text { text = "8" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_12",
                    value = settings.get("note_intervals", "enabled")[12] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[12] = value}))
                    end
                },
                dialog_vb:text { text = "12" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_16",
                    value = settings.get("note_intervals", "enabled")[16] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[16] = value}))
                    end
                },
                dialog_vb:text { text = "16" }
            }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_24",
                    value = settings.get("note_intervals", "enabled")[24] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[24] = value}))
                    end
                },
                dialog_vb:text { text = "24" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_32",
                    value = settings.get("note_intervals", "enabled")[32] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[32] = value}))
                    end
                },
                dialog_vb:text { text = "32" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_48",
                    value = settings.get("note_intervals", "enabled")[48] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[48] = value}))
                    end
                },
                dialog_vb:text { text = "48" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "interval_64",
                    value = settings.get("note_intervals", "enabled")[64] or false,
                    notifier = function(value)
                        settings.set("note_intervals", "enabled",
                            table.merge(settings.get("note_intervals", "enabled"), {[64] = value}))
                    end
                },
                dialog_vb:text { text = "64" }
            }
        }
    }
end

local function create_pattern_options_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Pattern Options",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:checkbox {
                id = "include_inverse",
                value = settings.get("pattern_options", "include_inverse"),
                notifier = function(value)
                    settings.set("pattern_options", "include_inverse", value)
                end
            },
            dialog_vb:text { text = "Include Inverse Patterns" }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:checkbox {
                id = "include_2x_variants",
                value = table.find(settings.get("pattern_options", "timing_multipliers") or {}, 2) ~= nil,
                notifier = function(value)
                    local multipliers = settings.get("pattern_options", "timing_multipliers") or {1}
                    if value and not table.find(multipliers, 2) then
                        table.insert(multipliers, 2)
                    elseif not value then
                        for i, mult in ipairs(multipliers) do
                            if mult == 2 then
                                table.remove(multipliers, i)
                                break
                            end
                        end
                    end
                    settings.set("pattern_options", "timing_multipliers", multipliers)
                end
            },
            dialog_vb:text { text = "Include Basic 2x Length Variants" }
        }
    }
end

local function create_beat_genres_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Beat Genres",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "genre_latin",
                    value = settings.get("beat_genres", "enabled")["l"] or false,
                    notifier = function(value)
                        local enabled = settings.get("beat_genres", "enabled")
                        enabled["l"] = value
                        settings.set("beat_genres", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Latin" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "genre_afro_cuban",
                    value = settings.get("beat_genres", "enabled")["u"] or false,
                    notifier = function(value)
                        local enabled = settings.get("beat_genres", "enabled")
                        enabled["u"] = value
                        settings.set("beat_genres", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Afro-Cuban" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "genre_afrobeat",
                    value = settings.get("beat_genres", "enabled")["a"] or false,
                    notifier = function(value)
                        local enabled = settings.get("beat_genres", "enabled")
                        enabled["a"] = value
                        settings.set("beat_genres", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Afrobeat" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "genre_jazz",
                    value = settings.get("beat_genres", "enabled")["j"] or false,
                    notifier = function(value)
                        local enabled = settings.get("beat_genres", "enabled")
                        enabled["j"] = value
                        settings.set("beat_genres", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Jazz" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "genre_funk",
                    value = settings.get("beat_genres", "enabled")["f"] or false,
                    notifier = function(value)
                        local enabled = settings.get("beat_genres", "enabled")
                        enabled["f"] = value
                        settings.set("beat_genres", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Funk" }
            }
        }
    }
end


local function create_augmentations_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Augmentations (for Rolls)",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_upshift",
                    value = settings.get("augmentations", "enabled")["Upshift"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Upshift"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Upshift" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_downshift",
                    value = settings.get("augmentations", "enabled")["Downshift"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Downshift"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Downshift" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_stretch",
                    value = settings.get("augmentations", "enabled")["Stretch"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Stretch"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Stretch" }
            }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_staccato",
                    value = settings.get("augmentations", "enabled")["Staccato"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Staccato"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Staccato" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_backwards",
                    value = settings.get("augmentations", "enabled")["Backwards"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Backwards"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Backwards" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "aug_reversal",
                    value = settings.get("augmentations", "enabled")["Reversal"] or false,
                    notifier = function(value)
                        local enabled = settings.get("augmentations", "enabled")
                        enabled["Reversal"] = value
                        settings.set("augmentations", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Reversal" }
            }
        }
    }
end

local function create_curves_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Curves (for Rolls & Offsets)",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_linear",
                    value = settings.get("curves", "enabled")["linear"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["linear"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Linear" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_logarithmic",
                    value = settings.get("curves", "enabled")["logarithmic"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["logarithmic"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Log" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_exponential",
                    value = settings.get("curves", "enabled")["exponential"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["exponential"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Exp" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_upParabola",
                    value = settings.get("curves", "enabled")["upParabola"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["upParabola"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Up↗" }
            }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_downParabola",
                    value = settings.get("curves", "enabled")["downParabola"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["downParabola"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Down↘" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_doublePeak",
                    value = settings.get("curves", "enabled")["doublePeak"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["doublePeak"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Peak⌒" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curve_doubleValley",
                    value = settings.get("curves", "enabled")["doubleValley"] or false,
                    notifier = function(value)
                        local enabled = settings.get("curves", "enabled")
                        enabled["doubleValley"] = value
                        settings.set("curves", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Valley⌄" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "curves_include_inverse",
                    value = settings.get("curves", "include_inverse"),
                    notifier = function(value)
                        settings.set("curves", "include_inverse", value)
                    end
                },
                dialog_vb:text { text = "Include Inverse" }
            }
        }
    }
end

local function create_euclidean_ranges_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Euclidean Ranges",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:text { text = "Pulses:" },
            dialog_vb:valuebox {
                id = "euc_pulse_min",
                min = 2,
                max = 11,
                value = settings.get("euclidean_ranges", "pulse_min"),
                width = 60,
                notifier = function(value)
                    settings.set("euclidean_ranges", "pulse_min", value)
                end
            },
            dialog_vb:text { text = "to" },
            dialog_vb:valuebox {
                id = "euc_pulse_max",
                min = 2,
                max = 11,
                value = settings.get("euclidean_ranges", "pulse_max"),
                width = 60,
                notifier = function(value)
                    settings.set("euclidean_ranges", "pulse_max", value)
                end
            },
            dialog_vb:text { text = "  Steps:" },
            dialog_vb:valuebox {
                id = "euc_step_min",
                min = 3,
                max = 12,
                value = settings.get("euclidean_ranges", "step_min"),
                width = 60,
                notifier = function(value)
                    settings.set("euclidean_ranges", "step_min", value)
                end
            },
            dialog_vb:text { text = "to" },
            dialog_vb:valuebox {
                id = "euc_step_max",
                min = 3,
                max = 12,
                value = settings.get("euclidean_ranges", "step_max"),
                width = 60,
                notifier = function(value)
                    settings.set("euclidean_ranges", "step_max", value)
                end
            }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:text { text = "Max Rotations:" },
            dialog_vb:valuebox {
                id = "euc_max_rotations",
                min = 1,
                max = 24,
                value = settings.get("euclidean_ranges", "max_rotations"),
                width = 50,
                notifier = function(value)
                    settings.set("euclidean_ranges", "max_rotations", value)
                end
            }
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "euc_half_speed",
                    value = settings.get("euclidean_ranges", "include_half_speed"),
                    notifier = function(value)
                        settings.set("euclidean_ranges", "include_half_speed", value)
                    end
                },
                dialog_vb:text { text = "Half Speed" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "euc_double_speed",
                    value = settings.get("euclidean_ranges", "include_double_speed"),
                    notifier = function(value)
                        settings.set("euclidean_ranges", "include_double_speed", value)
                    end
                },
                dialog_vb:text { text = "Double Speed" }
            }
        }
    }
end

local function create_shuffle_types_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Shuffle Types",
            font = "bold"
        },
        -- Row 1 (5 items)
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_basic_snare_hat",
                    value = settings.get("shuffle_types", "enabled")["basic_snare_hat_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["basic_snare_hat_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Basic S+H" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_syncopated_ghost",
                    value = settings.get("shuffle_types", "enabled")["syncopated_ghost_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["syncopated_ghost_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Sync Ghost" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_hat_driven",
                    value = settings.get("shuffle_types", "enabled")["hat_driven_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["hat_driven_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Hat Driven" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_complex",
                    value = settings.get("shuffle_types", "enabled")["complex_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["complex_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Complex" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_triplet_feel",
                    value = settings.get("shuffle_types", "enabled")["triplet_feel_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["triplet_feel_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Triplet Feel" }
            }
        },
        -- Row 2 (5 items)
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_kick_hat",
                    value = settings.get("shuffle_types", "enabled")["kick_hat_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["kick_hat_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Kick Hat" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_syncopated_kick",
                    value = settings.get("shuffle_types", "enabled")["syncopated_kick_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["syncopated_kick_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Sync Kick" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_ghost_kick",
                    value = settings.get("shuffle_types", "enabled")["ghost_kick_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["ghost_kick_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Ghost Kick" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_rolling_hat",
                    value = settings.get("shuffle_types", "enabled")["rolling_hat_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["rolling_hat_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Rolling Hat" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_interplay",
                    value = settings.get("shuffle_types", "enabled")["interplay_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["interplay_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Interplay" }
            }
        },
        -- Row 3 (5 items)
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_two_step",
                    value = settings.get("shuffle_types", "enabled")["two_step_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["two_step_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Two Step" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_sync_kick_snare",
                    value = settings.get("shuffle_types", "enabled")["syncopated_kick_snare_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["syncopated_kick_snare_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Sync K+S" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_rolling_snare",
                    value = settings.get("shuffle_types", "enabled")["rolling_snare_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["rolling_snare_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Roll Snare" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_complex_kick",
                    value = settings.get("shuffle_types", "enabled")["complex_kick_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["complex_kick_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Complex K" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "shuffle_ghost_groove",
                    value = settings.get("shuffle_types", "enabled")["ghost_groove_shuffle"] or false,
                    notifier = function(value)
                        local enabled = settings.get("shuffle_types", "enabled")
                        enabled["ghost_groove_shuffle"] = value
                        settings.set("shuffle_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Ghost Grv" }
            }
        }
    }
end

local function create_extras_panel(dialog_vb)
    return dialog_vb:column {
        margin = 5,
        style = "group",
        width = 450,
        dialog_vb:text {
            text = "Complex Roll Types",
            font = "bold"
        },
        dialog_vb:row {
            spacing = 5,
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "extras_paradiddles",
                    value = settings.get("extras_types", "enabled")["p"] or false,
                    notifier = function(value)
                        local enabled = settings.get("extras_types", "enabled")
                        enabled["p"] = value
                        settings.set("extras_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Paradiddles" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "extras_crossovers",
                    value = settings.get("extras_types", "enabled")["c"] or false,
                    notifier = function(value)
                        local enabled = settings.get("extras_types", "enabled")
                        enabled["c"] = value
                        settings.set("extras_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Crossovers" }
            },
            dialog_vb:row {
                dialog_vb:checkbox {
                    id = "extras_complex_rolls",
                    value = settings.get("extras_types", "enabled")["r"] or false,
                    notifier = function(value)
                        local enabled = settings.get("extras_types", "enabled")
                        enabled["r"] = value
                        settings.set("extras_types", "enabled", enabled)
                    end
                },
                dialog_vb:text { text = "Complex Rolls" }
            }
        }
    }
end

local function create_advanced_panel(dialog_vb)
    return dialog_vb:column {
        id = "advanced_panel",
        visible = advanced_enabled,  -- Set initial visibility based on state
        margin = 10,
        spacing = 5,
        style = "border",
        dialog_vb:text {
            text = "Advanced Options",
            font = "big",
            style = "strong"
        },
        -- Row 1: Note Intervals + Pattern Options
        dialog_vb:row {
            spacing = 10,
            dialog_vb:column {
                width = 450,
                create_note_intervals_panel(dialog_vb)
            },
            dialog_vb:column {
                width = 450,
                create_pattern_options_panel(dialog_vb)
            }
        },
        -- Row 2: Augmentations + Curves  
        dialog_vb:row {
            spacing = 10,
            dialog_vb:column {
                width = 450,
                create_augmentations_panel(dialog_vb)
            },
            dialog_vb:column {
                width = 450,
                create_curves_panel(dialog_vb)
            }
        },
        -- Row 3: Shuffle Types + Euclidean Ranges
        dialog_vb:row {
            spacing = 10,
            dialog_vb:column {
                width = 450,
                create_shuffle_types_panel(dialog_vb)
            },
            dialog_vb:column {
                width = 450,
                create_euclidean_ranges_panel(dialog_vb)
            }
        },
        -- Row 4: Beat Genres + Extras
        dialog_vb:row {
            spacing = 10,
            dialog_vb:column {
                width = 450,
                create_beat_genres_panel(dialog_vb)
            },
            dialog_vb:column {
                width = 450,
                create_extras_panel(dialog_vb)
            }
        },
        dialog_vb:horizontal_aligner {
            mode = "center",
            dialog_vb:row {
                spacing = 10,
                dialog_vb:button {
                    text = "Reset to Defaults",
                    notifier = function()
                        if settings and settings.reset_to_defaults then
                            settings.reset_to_defaults()
                            renoise.app():show_status("Advanced settings reset to defaults")
                        end
                    end
                },
                dialog_vb:button {
                    text = "Apply Settings",
                    notifier = function()
                        renoise.app():show_status("Advanced settings applied")
                    end
                }
            }
        }
    }
end

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

local function create_sample_offset_patterns(instrument_index)
  local song = renoise.song()
  local instrument = song:instrument(instrument_index + 1)
  local phrases = instrument.phrases
  
  if #phrases < 1 then
    renoise.app():show_warning("No phrases found in the selected instrument.")
    return
  end
  
  local original_phrase = phrases[1]
  local new_phrases, created_instruments = offsets.create_offset_patterns(instrument, original_phrase, labeler.saved_labels)
  
  if #new_phrases > 0 then
    offsets.show_results(new_phrases, created_instruments)
    renoise.app():show_status("Sample offset patterns created successfully.")
  end
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

    -- Collect composite symbols
    local composite_symbols = {}
    local symbols = {"U", "V", "W", "X", "Y", "Z"}
    
    for _, symbol in ipairs(symbols) do
        local symbol_view = dialog_vb.views["symbol_" .. string.lower(symbol)]
        if symbol_view and symbol_view.text ~= "" then
            composite_symbols[symbol] = symbol_view.text:upper()
        end
    end
    
    -- Parse break string with composite symbols
    local permutation, error = syntax.parse_break_string(break_string, #break_sets, composite_symbols)
    if not permutation then
        renoise.app():show_warning("Invalid break string: " .. error)
        return
    end
    
    -- Use existing break_sets and original_phrase
    breakpoints.sort_breaks(break_sets, original_phrase, true, permutation)
    
    -- Show status with resolved string if composites were used
    local resolved = syntax.resolve_break_string(break_string, composite_symbols)
    if resolved ~= break_string then
        renoise.app():show_status(string.format("Break pattern created. Original: %s, Resolved: %s", 
            break_string, resolved))
    else
        renoise.app():show_status("Break pattern created from string: " .. break_string)
    end
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
                syntax.import_syntax(vb)
              end
          },
        },
        vb:column {
          vb:button {
              text = "Export Syntax",
              width = 80,
              height = 20,
              notifier = function()
                syntax.export_syntax(vb)
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
          --[[
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
          ]]
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
      dialog_vb:checkbox {
        id = "humanize_checkbox",
        value = utils.humanize.enabled,
        notifier = function(value)
          utils.humanize.enabled = value
        end
      },
      dialog_vb:text {
        text = "Humanize Notes",
        font = "normal"
      }
    },
    dialog_vb:row {
      dialog_vb:text {
        text = "  Range:",
        width = 50
      },
      dialog_vb:text {
        text = "Min:",
        width = 30
      },
      dialog_vb:valuebox {
        id = "humanize_min",
        min = -255,
        max = 255,
        value = utils.humanize.min,
        width = 50,
        notifier = function(value)
          if value >= utils.humanize.max then
            renoise.app():show_warning("Minimum value must be lower than maximum value")
            dialog_vb.views.humanize_min.value = utils.humanize.min
            return
          end
          utils.humanize.min = value
        end
      },
      dialog_vb:text {
        text = "Max:",
        width = 30
      },
      dialog_vb:valuebox {
        id = "humanize_max",
        min = -255,
        max = 255,
        value = utils.humanize.max,
        width = 50,
        notifier = function(value)
          if value <= utils.humanize.min then
            renoise.app():show_warning("Maximum value must be higher than minimum value")
            dialog_vb.views.humanize_max.value = utils.humanize.max
            return
          end
          utils.humanize.max = value
        end
      }
    },
    dialog_vb:vertical_aligner { height = 5 },
    dialog_vb:row {
      dialog_vb:checkbox {
        id = "decay_checkbox",
        value = utils.decay_compensation.enabled,
        notifier = function(value)
          utils.decay_compensation.enabled = value
        end
      },
      dialog_vb:text {
        text = "Decay Compensation",
        font = "normal"
      }
    },
    dialog_vb:row {
      dialog_vb:text {
        text = "  Type:",
        width = 50
      },
      dialog_vb:popup {
        id = "decay_curve_type",
        items = {"Exponential", "Logarithmic", "Linear"},
        value = 1,
        width = 90,
        notifier = function(value)
          local curve_types = {"exponential", "logarithmic", "linear"}
          utils.decay_compensation.curve_type = curve_types[value]
        end
      },
      dialog_vb:text {
        text = "Offset:",
        width = 45
      },
      dialog_vb:valuebox {
        id = "decay_offset",
        min = 0,
        max = 16,
        value = utils.decay_compensation.offset,
        width = 70,
        notifier = function(value)
          utils.decay_compensation.offset = value
        end
      },
      dialog_vb:text {
        text = "Min Vol:",
        width = 50
      },
      dialog_vb:valuebox {
        id = "decay_min_volume",
        min = 0,
        max = 255,  -- Changed from 128
        value = utils.decay_compensation.min_volume,
        width = 45,
        notifier = function(value)
          utils.decay_compensation.min_volume = value
        end
      }
    },
    dialog_vb:vertical_aligner { height = 5 },
    dialog_vb:vertical_aligner { height = 10 },
    dialog_vb:row {
      dialog_vb:checkbox {
        id = "advanced_toggle",
        value = advanced_enabled,
        notifier = function(value)
          advanced_enabled = value
          -- Toggle visibility of advanced panel
          if dialog_vb.views.advanced_panel then
            dialog_vb.views.advanced_panel.visible = value
          end
        end
      },
      dialog_vb:text {
        text = "Advanced Options",
        font = "bold"
      }
    },
    -- Advanced panel - always present but visibility controlled
    create_advanced_panel(dialog_vb),
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
      },
      dialog_vb:button {
        text = "Generate Sample Offsets",
        notifier = function()
          local instrument_index = dialog_vb.views.instrument_index.value
          create_sample_offset_patterns(instrument_index)
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
