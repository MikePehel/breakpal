-- settings.lua
local settings = {}
local config = require("config")

-- Default settings that can be overridden by advanced menu
settings.defaults = {
    -- Note intervals for all generators
    note_intervals = {
        enabled = {},  -- Will be populated from config
        selected = config.EXTENDED_DIVISIONS
    },
    
    -- Pattern generation options
    pattern_options = {
        include_inverse = true,
        timing_multipliers = {1, 2}  -- 1x and 2x variants
    },
    
    -- Curve types for rollers and offsets
    curves = {
        enabled = {},  -- Will be populated from config
        selected = config.CURVE_TYPES,
        include_inverse = true
    },
    
    -- Augmentations for rollers
    augmentations = {
        enabled = {},  -- Will be populated from config
        selected = config.AUGMENTATION_TYPES
    },
    
    -- Beat genres for beat generator
    beat_genres = {
        enabled = {},  -- Will be populated from config  
        selected = {"l", "u", "a", "j", "f"}  -- All genres enabled by default
    },
    
    -- Extras categories for extras generator
    extras_types = {
        enabled = {},  -- Will be populated from config
        selected = {"p", "c", "r"}  -- All types enabled by default
    },
    
    -- Euclidean pattern ranges
    euclidean_ranges = {
        pulse_min = config.EUCLIDEAN_RANGES.pulse_min,
        pulse_max = config.EUCLIDEAN_RANGES.pulse_max,
        step_min = config.EUCLIDEAN_RANGES.step_min,
        step_max = config.EUCLIDEAN_RANGES.step_max,
        max_rotations = config.EUCLIDEAN_RANGES.max_rotations,
        include_half_speed = true,
        include_double_speed = true
    },
    
    -- Shuffle types for shuffle generator
    shuffle_types = {
        enabled = {},  -- Will be populated from config
        selected = {}  -- Will be populated from config
    },
    
    -- Timing divisions used across generators
    timing_divisions = {
        standard = config.STANDARD_DIVISIONS,
        extended = config.EXTENDED_DIVISIONS
    },
    
    -- Slice filtering options
    slice_filters = {
        mode = "all",  -- "all", "tagged_only", "custom"
        included_labels = {},  -- populated dynamically based on current labels
        excluded_labels = {}
    }
}

-- Initialize enabled arrays from config
local function initialize_enabled_arrays()
    -- Note intervals
    for _, interval in ipairs(config.EXTENDED_DIVISIONS) do
        settings.defaults.note_intervals.enabled[interval] = true
    end
    
    -- Curve types  
    for _, curve in ipairs(config.CURVE_TYPES) do
        settings.defaults.curves.enabled[curve] = true
    end
    
    -- Augmentations
    for _, aug in ipairs(config.AUGMENTATION_TYPES) do
        settings.defaults.augmentations.enabled[aug] = true
    end
    
    -- Beat genres
    for flag, name in pairs(config.BEAT_GENRES) do
        settings.defaults.beat_genres.enabled[flag] = true
    end
    
    -- Extras types
    for flag, name in pairs(config.EXTRAS_TYPES) do
        settings.defaults.extras_types.enabled[flag] = true
    end
    
    -- Shuffle types
    for _, shuffle_config in ipairs(config.SHUFFLE_TYPES) do
        settings.defaults.shuffle_types.enabled[shuffle_config.template] = true
        table.insert(settings.defaults.shuffle_types.selected, shuffle_config.template)
    end
end

-- Initialize on module load
initialize_enabled_arrays()

-- Current active settings (starts as copy of defaults, modified by advanced menu)
settings.current = {}

-- Deep copy function for tables
local function deep_copy(original)
    local copy = {}
    for key, value in pairs(original) do
        if type(value) == "table" then
            copy[key] = deep_copy(value)
        else
            copy[key] = value
        end
    end
    return copy
end

-- Initialize current settings as deep copy of defaults
settings.current = deep_copy(settings.defaults)

-- Settings API functions
function settings.get(category, key)
    if key then
        return settings.current[category] and settings.current[category][key]
    else
        return settings.current[category]
    end
end

function settings.set(category, key, value)
    if not settings.current[category] then
        settings.current[category] = {}
    end
    
    if key then
        settings.current[category][key] = value
    else
        settings.current[category] = value
    end
end

-- Get filtered arrays based on current settings
function settings.get_enabled_note_intervals()
    local result = {}
    for _, interval in ipairs(config.EXTENDED_DIVISIONS) do
        if settings.current.note_intervals.enabled[interval] then
            table.insert(result, interval)
        end
    end
    return result
end

function settings.get_enabled_curves()
    local result = {}
    for _, curve in ipairs(config.CURVE_TYPES) do
        if settings.current.curves.enabled[curve] then
            table.insert(result, curve)
        end
    end
    return result
end

function settings.get_enabled_augmentations()
    local result = {}
    for _, aug in ipairs(config.AUGMENTATION_TYPES) do
        if settings.current.augmentations.enabled[aug] then
            table.insert(result, aug)
        end
    end
    return result
end

function settings.get_enabled_beat_genres()
    local result = {}
    for flag, name in pairs(config.BEAT_GENRES) do
        if settings.current.beat_genres.enabled[flag] then
            result[flag] = name
        end
    end
    return result
end

function settings.get_enabled_extras_types()
    local result = {}
    for flag, name in pairs(config.EXTRAS_TYPES) do
        if settings.current.extras_types.enabled[flag] then
            result[flag] = name
        end
    end
    return result
end

function settings.get_enabled_shuffle_types()
    local result = {}
    for _, shuffle_config in ipairs(config.SHUFFLE_TYPES) do
        if settings.current.shuffle_types.enabled[shuffle_config.template] then
            table.insert(result, shuffle_config)
        end
    end
    return result
end

-- Reset settings to defaults
function settings.reset_to_defaults()
    settings.current = deep_copy(settings.defaults)
end

-- Get euclidean patterns based on current range settings
function settings.get_euclidean_range()
    return {
        pulse_min = settings.current.euclidean_ranges.pulse_min,
        pulse_max = settings.current.euclidean_ranges.pulse_max,
        step_min = settings.current.euclidean_ranges.step_min,
        step_max = settings.current.euclidean_ranges.step_max,
        max_rotations = settings.current.euclidean_ranges.max_rotations
    }
end

-- Check if pattern options are enabled
function settings.include_inverse_patterns()
    return settings.current.pattern_options.include_inverse
end

function settings.get_timing_multipliers()
    return settings.current.pattern_options.timing_multipliers
end

-- Debug function to print current settings
function settings.debug_print()
    print("=== Current Settings ===")
    for category, data in pairs(settings.current) do
        print(string.format("%s:", category))
        if type(data) == "table" then
            for key, value in pairs(data) do
                print(string.format("  %s: %s", key, tostring(value)))
            end
        else
            print(string.format("  %s", tostring(data)))
        end
    end
    print("=======================")
end

return settings