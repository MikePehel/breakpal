-- config.lua
local config = {}

-- Note intervals available across all generators
config.NOTE_INTERVALS = {2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64}

-- All curve types supported by utils.generate_curve()
config.CURVE_TYPES = {
    "linear", "logarithmic", "exponential", 
    "upParabola", "downParabola", 
    "doublePeak", "doubleValley"
}

-- All augmentation types supported by utils.augment_phrase()
config.AUGMENTATION_TYPES = {
    "Upshift", "Downshift", "Stretch", 
    "Staccato", "Backwards", "Reversal"
}

-- Beat genre flags and their display names
config.BEAT_GENRES = {
    l = "Latin",
    u = "Afro Cuban", 
    a = "Afrobeat",
    j = "Jazz",
    f = "Funk"
}

-- Extras pattern flags and their display names
config.EXTRAS_TYPES = {
    p = "Paradiddles",
    c = "Crossovers", 
    r = "Complex Rolls"
}

-- Timing variation multipliers used across generators
config.TIMING_MULTIPLIERS = {0.5, 0.75, 1, 1.5, 2}

-- Standard timing divisions used by most generators
config.STANDARD_DIVISIONS = {4, 6, 8, 12, 16}

-- Extended timing divisions used by rollers
config.EXTENDED_DIVISIONS = {2, 3, 4, 6, 8, 12, 16, 24, 32, 48, 64}

-- Euclidean pattern ranges
config.EUCLIDEAN_RANGES = {
    pulse_min = 2,
    pulse_max = 11,
    step_min = 3,
    step_max = 12,
    max_rotations = 12
}

-- Shuffle pattern definitions
config.SHUFFLE_TYPES = {
    {name = "Basic Snare Hat", template = "basic_snare_hat_shuffle"},
    {name = "Syncopated Ghost", template = "syncopated_ghost_shuffle"},
    {name = "Hat Driven", template = "hat_driven_shuffle"},
    {name = "Complex", template = "complex_shuffle"},
    {name = "Triplet Feel", template = "triplet_feel_shuffle"},
    {name = "Basic Kick Hat", template = "kick_hat_shuffle"},
    {name = "Syncopated Kick", template = "syncopated_kick_shuffle"},
    {name = "Ghost Kick", template = "ghost_kick_shuffle"},
    {name = "Rolling Hat", template = "rolling_hat_shuffle"},
    {name = "Kick Hat Interplay", template = "interplay_shuffle"},
    {name = "Two Step", template = "two_step_shuffle"},
    {name = "Syncopated Kick Snare", template = "syncopated_kick_snare_shuffle"},
    {name = "Rolling Snare", template = "rolling_snare_shuffle"},
    {name = "Complex Kick", template = "complex_kick_shuffle"},
    {name = "Ghost Groove", template = "ghost_groove_shuffle"}
}

return config