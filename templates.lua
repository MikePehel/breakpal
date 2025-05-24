local templates = {}
local vb = renoise.ViewBuilder()
--TODO Add more genres to beat templates


--Paradiddles & Crossovers
templates._p_paradiddle = {
    R = "R.RR|.R..|R.RR|.R..",
    L = ".L..|L.LL|.L..|L.LL",
    steps = 16
}

templates._p_dbl_paradiddle = {
    R = "R.R.|RR.R|.R..",
    L = ".L.L|..L.|L.LL",
    steps = 12
}

templates._p_trpl_paradiddle = {
    R = "R.R.|R.RR|.R.R|.R..",
    L = ".L.L|.L..|L.L.|L.LL",
    steps  = 16  
}


templates._c_crossover = {
    R = "R..R|R.R.|.RR.|.R.R",
    L = ".LL.|.L.L|L..L|L.L.",
    V = "4848|4868|6868|4868",
    steps  = 16  

}

templates._c_dbl_crossover = {
    R = "R..R|R..R|.RR.|.RR.",
    L = ".LL.|.LL.|L..L|L..L",
    V = "4848|4646|4848|4646",
    steps  = 16  

}

--Complex Rolls
templates._r_syncopated_roll = {
    R = "R...|R...",
    L = "...L|...L",
    steps  = 8   
}


templates._r_bouncing_decay_roll__ = {
    R = "R.R.|R...|R...|..R.|....|..R.|....|....",
    L = ".L.L|..L.|...L|....|..L.|....|...L|....",
    steps  = 16  
}

templates._r_downbeat_accent_roll = {
    R = "R.R.|....",
    L = ".L.L|..L.",
    V = "1234|..8.",
    steps  = 8  
}

templates._m_multi_roll = {
    R = "R...|R...",
    L = "..L.|..L.",
    G = ".G..|.G..",
    H = "...H|...H",
    steps  = 8
}

templates._m_weak_hand = {
    R = ".R..|.R..",
    L = "...L|...L",
    G = "G...|G...",
    H = "..H.|..H.",
    steps  = 8
}

templates._m_weak_strong = {
    R = "....|R.R.",
    L = "....|.L.L",
    G = "G.G.|....",
    H = ".H.H|....",
    steps = 8    
}

templates._m_strong_weak = {
    R = "R.R.|....",
    L = ".L.L|....",
    G = "....|G.G.",
    H = "....|.H.H",
    steps = 8    
}


--Shuffle Templates
templates.basic_snare_hat_shuffle = {
    S = "....|S...|....|S...", 
    G = ".G.G|....|.G.G|....",
    H = "H.H.|.H.H|H.H.|.H.H",
}

templates.syncopated_ghost_shuffle = {
    S = "....|S...|....|....", 
    G = "G..G|.G..|..G.|G...",
    H = ".H..|..H.|.H.H|..H."
}

templates.hat_driven_shuffle = {
    S = "....|S...|....|....", 
    G = ".G..|..G.|.G..|..G.",
    H = "H..H|H..H|H..H|H..H"
}

templates.complex_shuffle = {
    S = "....|S...|....|S...", 
    G = "G.G.|.G..|G..G|.G..",
    H = ".H.H|...H|.H..|...H"
}

templates.triplet_feel_shuffle = {
    S = "....|S...|....|S...", 
    G = "..G.|.G..|..G.|...G",
    H = ".H.H|...H|.H.H|.H.."
}

templates.kick_hat_shuffle = {
    K = "K...|....|K...|....", 
    H = "..H.|.H.H|..H.|.H.H"
}

templates.syncopated_kick_shuffle = {
    K = "K...|..K.|K...|.K..", 
    H = "..H.|H...|..H.|H.H."
}

templates.ghost_kick_shuffle = {
    K = "K...|....|K...|....", 
    L = "..L.|..L.|..L.|..L.",
    H = ".H.H|H..H|.H.H|H..H"
}

templates.rolling_hat_shuffle = {
    K = "K...|..K.|K...|....", 
    H = ".HHH|HH.H|.HHH|HHHH"
}

templates.interplay_shuffle = {
    K = "K...|.K..|..K.|K...", 
    L = "....|...L|....|...L",
    H = ".H.H|H...|.H.H|H..."
}

templates.two_step_shuffle = {
    K = "K...|...K|..K.|....", 
    S = "....|S...|....|S...",
    G = ".G.G|....|.G.G|...."
}

templates.syncopated_kick_snare_shuffle = {
    K = "K...|.K..|K...|..K.", 
    S = "....|S...|....|S...",
    G = "...G|...G|.G..|...G"
}

templates.rolling_snare_shuffle = {
    K = "K...|....|K...|....", 
    S = "....|S...|....|S...",
    G = ".GG.|.GG.|.GG.|.GG."
}

templates.complex_kick_shuffle = {
    K = "K.K.|..K.|K..K|....", 
    S = "....|S...|....|S...",
    G = "...G|....|.G..|...."
}

templates.ghost_groove_shuffle = {
    K = "K...|....|K...|....", 
    S = "....|S...|....|S...",
    G = "..G.|.G.G|..G.|.G.G"
}


--Multi-Instrument Templates

-- Latin
----Samba
templates._l_basic_samba = {
    K = "K...K...K...K...|K...K...K...K...|K...K...K...K...|K...K...K...K...",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO",
    G = "..G...G...G...G.|..G...G...G...G.|..G...G...G...G.|..G...G...G...G."
}

templates._l_traditional_samba = {
    K = "K...K.K.K...K.K.|K...K.K.K...K.K.|K...K.K.K...K.K.|K...K.K.K...K.K.",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO",
    G = "..G...G...G...G.|..G...G...G...G.|..G...G...G...G.|..G...G...G...G."
}

templates._l_syncopated_samba = {
    K = "K.K.....K.K.....|K.K.....K.K.....|K.K.....K.K.....|K.K.....K.K.....",
    S = "....S.......S...|....S.........S.|....S.......S...|....S.........S.",
    H = "H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO",
    G = "..G...G...G...G.|......G.....G...|..G...G...G...G.|......G.....G..."    
}

templates._l_modern_samba = {
    K = "K...K...K.K.K...|K...K...K.K.K...|K...K...K.K.K...|K...K...K.K.K...",
    S = "....S.S.......S.|....S.S.......S.|....S.S.......S.|....S.S.......S.",
    H = "H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "..G.....G...G...|..G.....G...G...|..G.....G...G...|..G.....G...G..."
    
}

---- Afro Cuban
templates._u_san_clave = {
    K = "K.....K.K....K..|K.....K.K....K..|K.....K.K....K..|K.....K.K....K..",
    S = "....S.....S.....|....S.....S.....|....S.....S.....|....S.....S.....",
    H = "H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO",
    G = "..G...G.......G.|..G.....G...G...|..G...G.......G.|..G.....G...G..."    
}

templates._u_rumba_clave = {
    K = "K...K...K.K.....|K...K...K.K.....|K...K...K.K.....|K...K...K.K.....",
    S = "....S.....S.....|....S.....S.S...|....S.....S.S...|....S.....S.S...",
    H = "H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.H.|H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "G.....G.....G...|G.....G.........|G.....G.........|G.....G........."    
}

templates._u_mozambique = {
    K = "K..K..K...K.....|K..K..K...K.....|K..K..K...K.....|K..K..K...K.....",
    S = "......S...S...S.|......S...S...S.|......S...S...S.|......S...S...S.",
    H = "H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO",
    G = "G...G...G...G...|G...G...G...G...|G...G...G...G...|G...G...G...G..."  
}

templates._u_guaguanco = {
    K = "K.K...K...K.K...|K.K...K...K.K...|K.K...K...K.K...|K.K...K...K.K...",
    S = "....S.S...S.....|....S.S...S.....|....S.S...S.....|....S.S...S.....",
    H = "H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "..G.....G.....G.|..G.....G.....G.|..G.....G.....G.|..G.....G.....G."  
}

--Afrobeat
templates._a_fela_style = {
    K = "K..K..K...K.K...|K..K..K...K.K...|K..K..K...K.K...|K..K..K...K.K...",
    S = "....S.....S.S...|....S.....S.S...|....S.....S.S...|....S.....S.S...",
    H = "H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO",
    G = "G.G.....G.......|G.G.....G.......|G.G.....G.......|G.G.....G......."    
}

templates._a_allen_style = {
    K = "K...K.K...K.....|K...K.K...K.....|K...K.K...K.....|K...K.K...K.....",
    S = "....S...S...S.S.|....S...S...S.S.|....S...S...S.S.|....S...S...S.S.",
    H = "H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "G.G.............|G.G.............|G.G.............|G.G............."    
}

templates._a_lagos_shuffle = {
    K = "K.K...K.K...K...|K.K...K.K...K...|K.K...K.K...K...|K.K...K.K...K...",
    S = "....S.S.....S.S.|....S.S.....S.S.|....S.S.....S.S.|....S.S.....S.S.",
    H = "H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "G.........G.....|G.........G.....|G.........G.....|G.........G....."    
}

templates._a_lagos_twist = {
    K = "K..K.K..K.K..K..|K..K.K..K.K..K..|K..K.K..K.K..K..|K..K.K..K.K..K..",
    S = "....S...S.S.....|....S...S.S.....|....S...S.S.....|....S...S.S.....",
    H = "H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.HO",
    G = "G............G..|G............G..|G............G..|G............G.."    
}

--Jazz
templates._j_basic_swing = {
    K = "K.......K.......|K.......K.......|K.......K.......|K.......K.......",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H..H.H..H..H.H..|H..H.H..H..H.H..|H..H.H..H..H.H..|H..H.H..H..H.H..",
    G = "...G.....G...G..|...G.....G...G..|...G.....G...G..|...G.....G...G.."    
}

templates._j_bebop = {
    K = "K.......K...K...|K.......K...K...|K.......K...K...|K.......K...K...",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H..H.H..H..H.H.O|H..H.H..H..H.H..|H..H.H..H..H.H.O|H..H.H..H..H.H..",
    G = "G.......G.......|G.......G.......|G.......G.......|G.......G......."    
    
}

templates._j_jazz_waltz = {
    K = "K.....K.........|K.....K.........|K.....K.........|K.....K.........",
    S = "....S.....S.....|....S.....S.....|....S.....S.....|....S.....S.....",
    H = "H..H.H..H..H.H..|H..H.H..H..H.H.O|H..H.H..H..H.H..|H..H.H..H..H.H.O",
    G = ".G.......G......|.G.......G......|.G.......G......|.G.......G......"    
    
}
templates._j_hard_bop = {
    K = "K.......K..K....|K.......K..K....|K.......K..K....|K.......K..K....",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H..H.H..H..H.H.O|H..H.H..H..H.H..|H..H.H..H..H.H.O|H..H.H..H..H.H..",
    G = "...G..G.........|...G..G.........|...G..G.........|...G..G........."    
    
}
templates._j_contemporary_jazz = {
    K = "K.....K.K.......|K.....K.K.......|K.....K.K.......|K.....K.K.......",
    S = "....S.......S...|....S.......S...|....S.......S...|....S.......S...",
    H = "H..H.H..H..H.H.O|H..H.H..H..H.H..|H..H.H..H..H.H.O|H..H.H..H..H.H..",
    G = "...G..G.........|...G..G.........|...G..G.........|...G..G........."    
    
}

--Funk
templates._f_classic_funk = {
    K = "K.....K...K.....|K.....K...K.....|K.....K...K.....|K.....K...K.....",
    S = "....S.....S...S.|....S.....S...S.|....S.....S...S.|....S.....S...S.",
    H = "H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.HO",
    G = "G...........G...|G...........G...|G...........G...|G...........G..."    
    
}

templates._f_syncopated_funk = {
    K = "K..K..K...K.K...|K..K..K...K.K...|K..K..K...K.K...|K..K..K...K.K...",
    S = "...S...S....S...|...S...S....S...|...S...S....S...|...S...S....S...",
    H = "H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.H.|H.H.H.HOH.H.H.H.",
    G = ".G.......G......|.G.......G......|.G.......G......|.G.......G......"    

}

templates._f_new_orleans_funk = {
    K = "K..K...K..K...K.|K..K...K..K...K.|K..K...K..K...K.|K..K...K..K...K.",
    S = "....S.....S.....|....S.....S.....|....S.....S.....|....S.....S.....",
    H = "H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO|H.H.H.H.H.H.H.H.|H.H.H.H.H.H.H.HO",
    G = ".....G.......G..|.....G.......G..|.....G.......G..|.....G.......G.."    

}

templates._f_modern_pocket = {
    K = "K.K...K...K.K...|K.K...K...K.K...|K.K...K...K.K...|K.K...K...K.K...",
    S = "....S.....S.....|....S.....S.....|....S.....S.....|....S.....S.....",
    H = "H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO|H.H.H.HOH.H.H.HO",
    G = ".......G......G.|.......G......G.|.......G......G.|.......G......G."    

}

--Linear
templates._i_basic_linear = {
    P = "K..H.S.H.K..H.S.|K..H.S.H.K..H.S.|K..H.S.H.K..H.S.|K..H.S.H.K..H.S."

}

templates._i_linear_funk = {
    P = "K.H.S.H.K.G.H.S.|K.H.S.H.K.G.H.S.|K.H.S.H.K.G.H.S.|K.H.S.H.K.G.H.S."

}

templates._i_linear_latin = {
    P = "K.H.S.G.K.H.S.H.|K.H.S.G.K.H.S.H.|K.H.S.G.K.H.S.H.|K.H.S.G.K.H.S.H."

}

templates._i_complex_linear = {
    P = "K.H.S.G.H.S.K.H.|S.G.H.K.S.H.G.H.|K.H.S.G.H.S.K.H.|S.G.H.K.S.H.G.H."

}

templates._i_advanced_linear = {
    K = "K.O.S.G.H.G.K.O.|S.G.H.K.S.O.G.H.|K.H.S.G.O.S.k.H.|S.G.O.K.G.H.G.O.",
    V = "8.8.8.4.8.4.4.8.|4.8.8.8.8.8.8.8.|8.8.4.8.8.8.4.8.|8.4.8.8.4.8.8.8."
}

--Euclideans
--Group 1
templates._2_3euclidean = {
    x = "-xx",
    shifts = 3
}

templates._2_5euclidean = {
    x = "--x-x",
    shifts = 5
}

templates._2_7euclidean = {
    x = "---x--x",
    shifts = 7
}

templates._2_9euclidean = {
    x = "----x---x",
    shifts = 9
}

templates._2_11euclidean = {
    x = "-----x----x",
    shifts = 11
}

templates._3_4euclidean = {
    x = "-xxx",
    shifts = 4
}

templates._3_5euclidean = {
    x = "-x-xx",
    shifts = 5
}

templates._3_7euclidean = {
    x = "--x-x-x",
    shifts = 7
}

templates._3_8euclidean = {
    x = "--x--x-x",
    shifts = 8
}

templates._3_10euclidean = {
    x = "---x--x--x",
    shifts = 10
}

templates._3_11euclidean = {
    x = "---x---x--x",
    shifts = 11
}

templates._4_5euclidean = {
    x = "-xxxx",
    shifts = 5
}

templates._4_6euclidean = {
    x = "-xx-xx",
    shifts = 3
}

templates._4_7euclidean = {
    x = "-x-x-xx",
    shifts = 7
}

templates._4_9euclidean = {
    x = "--x-x-x-x",
    shifts = 9
}

templates._4_10euclidean = {
    x = "--x-x--x-x",
    shifts = 5
}

templates._4_11euclidean = {
    x = "--x--x--x-x",
    shifts = 11
}

--Group 2

templates._5_6euclidean = {
    x = "-xxxxx",
    shifts = 6
}

templates._5_7euclidean = {
    x = "-xx-xxx",
    shifts = 7
}

templates._5_8euclidean = {
    x = "-x-xx-xx",
    shifts = 8
}

templates._5_9euclidean = {
    x = "-x-x-x-xx",
    shifts = 9
}

templates._5_11euclidean = {
    x = "--x-x-x-x-x",
    shifts = 11
}

templates._5_12euclidean = {
    x = "--x-x--x-x-x",
    shifts = 12
}

templates._6_7euclidean = {
    x = "-xxxxxx",
    shifts = 7
}

templates._6_8euclidean = {
    x = "-xxx-xxx",
    shifts = 4
}

templates._6_9euclidean = {
    x = "-xx-xx-xx",
    shifts = 3
}

templates._6_10euclidean = {
    x = "-x-xx-x-xx",
    shifts = 5
}

templates._6_11euclidean = {
    x = "-x-x-x-x-xx",
    shifts = 11
}

--Group 3

templates._7_8euclidean = {
    x = "-xxxxxxx",
    shifts = 8
}

templates._7_9euclidean = {
    x = "-xxx-xxxx",
    shifts = 9
}

templates._7_10euclidean = {
    x = "-xx-xx-xxx",
    shifts = 10
}

templates._7_11euclidean = {
    x = "-x-xx-xx-xx",
    shifts = 11
}

templates._7_12euclidean = {
    x = "-x-x-xx-x-xx",
    shifts = 12
}

templates._8_9euclidean = {
    x = "-xxxxxxxx",
    shifts = 9
}

templates._8_10euclidean = {
    x = "-xxxx-xxxx",
    shifts = 5
}

templates._8_11euclidean = {
    x = "-xx-xxx-xxx",
    shifts = 11
}

templates._9_10euclidean = {
    x = "-xxxxxxxxx",
    shifts = 10
}

templates._9_11euclidean = {
    x = "-xxxx-xxxxx",
    shifts = 11
}

templates._9_12euclidean = {
    x = "-xxx-xxx-xxx",
    shifts = 4
}

--Group 4

templates._10_11euclidean = {
    x = "-xxxxxxxxxx",
    shifts = 11
}

templates._10_12euclidean = {
    x = "-xxxxx-xxxxx",
    shifts = 6
}

templates._11_11euclidean = {
    x = "xxxxxxxxxxx",
    shifts = 1
}

templates._11_12euclidean = {
    x = "-xxxxxxxxxxx",
    shifts = 12
}


-- Template metadata for categorization and filtering
templates.metadata = {
    -- Beat patterns - Latin
    _l_basic_samba = {type = "beat", genre = "l", name = "Basic Samba"},
    _l_traditional_samba = {type = "beat", genre = "l", name = "Traditional Samba"},
    _l_syncopated_samba = {type = "beat", genre = "l", name = "Syncopated Samba"},
    _l_modern_samba = {type = "beat", genre = "l", name = "Modern Samba"},
    
    -- Beat patterns - Afro Cuban
    _u_san_clave = {type = "beat", genre = "u", name = "Son Clave"},
    _u_rumba_clave = {type = "beat", genre = "u", name = "Rumba Clave"},
    _u_mozambique = {type = "beat", genre = "u", name = "Mozambique"},
    _u_guaguanco = {type = "beat", genre = "u", name = "Guaguanco"},
    
    -- Beat patterns - Afrobeat
    _a_fela_style = {type = "beat", genre = "a", name = "Fela Style"},
    _a_allen_style = {type = "beat", genre = "a", name = "Tony Allen Style"},
    _a_lagos_shuffle = {type = "beat", genre = "a", name = "Lagos Shuffle"},
    _a_lagos_twist = {type = "beat", genre = "a", name = "Lagos Twist"},
    
    -- Beat patterns - Jazz
    _j_basic_swing = {type = "beat", genre = "j", name = "Basic Swing"},
    _j_bebop = {type = "beat", genre = "j", name = "Bebop"},
    _j_jazz_waltz = {type = "beat", genre = "j", name = "Jazz Waltz"},
    _j_hard_bop = {type = "beat", genre = "j", name = "Hard Bop"},
    _j_contemporary_jazz = {type = "beat", genre = "j", name = "Contemporary Jazz"},
    
    -- Beat patterns - Funk
    _f_classic_funk = {type = "beat", genre = "f", name = "Classic Funk"},
    _f_syncopated_funk = {type = "beat", genre = "f", name = "Syncopated Funk"},
    _f_new_orleans_funk = {type = "beat", genre = "f", name = "New Orleans Funk"},
    _f_modern_pocket = {type = "beat", genre = "f", name = "Modern Pocket"},
    
    -- Linear patterns
    _i_basic_linear = {type = "beat", genre = "i", name = "Basic Linear"},
    _i_linear_funk = {type = "beat", genre = "i", name = "Linear Funk"},
    _i_linear_latin = {type = "beat", genre = "i", name = "Linear Latin"},
    _i_complex_linear = {type = "beat", genre = "i", name = "Complex Linear"},
    _i_advanced_linear = {type = "beat", genre = "i", name = "Advanced Linear"},
    
    -- Extras patterns - Paradiddles
    _p_paradiddle = {type = "extras", category = "p", name = "Paradiddle"},
    _p_dbl_paradiddle = {type = "extras", category = "p", name = "Double Paradiddle"},
    _p_trpl_paradiddle = {type = "extras", category = "p", name = "Triple Paradiddle"},
    
    -- Extras patterns - Crossovers
    _c_crossover = {type = "extras", category = "c", name = "Crossover"},
    _c_dbl_crossover = {type = "extras", category = "c", name = "Double Crossover"},
    
    -- Extras patterns - Rolls
    _r_syncopated_roll = {type = "extras", category = "r", name = "Syncopated Roll"},
    _r_bouncing_decay_roll__ = {type = "extras", category = "r", name = "Bouncing Decay Roll"},
    _r_downbeat_accent_roll = {type = "extras", category = "r", name = "Downbeat Accent Roll"},
    
    -- Multi patterns
    _m_multi_roll = {type = "multi", name = "Multi Roll"},
    _m_weak_hand = {type = "multi", name = "Weak Hand"},
    _m_weak_strong = {type = "multi", name = "Weak Strong"},
    _m_strong_weak = {type = "multi", name = "Strong Weak"},
    
    -- Euclidean patterns - Group 1
    _2_3euclidean = {type = "euclidean", pulses = 2, steps = 3, group = 1},
    _2_5euclidean = {type = "euclidean", pulses = 2, steps = 5, group = 1},
    _2_7euclidean = {type = "euclidean", pulses = 2, steps = 7, group = 1},
    _2_9euclidean = {type = "euclidean", pulses = 2, steps = 9, group = 1},
    _2_11euclidean = {type = "euclidean", pulses = 2, steps = 11, group = 1},
    _3_4euclidean = {type = "euclidean", pulses = 3, steps = 4, group = 1},
    _3_5euclidean = {type = "euclidean", pulses = 3, steps = 5, group = 1},
    _3_7euclidean = {type = "euclidean", pulses = 3, steps = 7, group = 1},
    _3_8euclidean = {type = "euclidean", pulses = 3, steps = 8, group = 1},
    _3_10euclidean = {type = "euclidean", pulses = 3, steps = 10, group = 1},
    _3_11euclidean = {type = "euclidean", pulses = 3, steps = 11, group = 1},
    _4_5euclidean = {type = "euclidean", pulses = 4, steps = 5, group = 1},
    _4_6euclidean = {type = "euclidean", pulses = 4, steps = 6, group = 1},
    _4_7euclidean = {type = "euclidean", pulses = 4, steps = 7, group = 1},
    _4_9euclidean = {type = "euclidean", pulses = 4, steps = 9, group = 1},
    _4_10euclidean = {type = "euclidean", pulses = 4, steps = 10, group = 1},
    _4_11euclidean = {type = "euclidean", pulses = 4, steps = 11, group = 1},
    
    -- Euclidean patterns - Group 2
    _5_6euclidean = {type = "euclidean", pulses = 5, steps = 6, group = 2},
    _5_7euclidean = {type = "euclidean", pulses = 5, steps = 7, group = 2},
    _5_8euclidean = {type = "euclidean", pulses = 5, steps = 8, group = 2},
    _5_9euclidean = {type = "euclidean", pulses = 5, steps = 9, group = 2},
    _5_11euclidean = {type = "euclidean", pulses = 5, steps = 11, group = 2},
    _5_12euclidean = {type = "euclidean", pulses = 5, steps = 12, group = 2},
    _6_7euclidean = {type = "euclidean", pulses = 6, steps = 7, group = 2},
    _6_8euclidean = {type = "euclidean", pulses = 6, steps = 8, group = 2},
    _6_9euclidean = {type = "euclidean", pulses = 6, steps = 9, group = 2},
    _6_10euclidean = {type = "euclidean", pulses = 6, steps = 10, group = 2},
    _6_11euclidean = {type = "euclidean", pulses = 6, steps = 11, group = 2},
    
    -- Euclidean patterns - Group 3
    _7_8euclidean = {type = "euclidean", pulses = 7, steps = 8, group = 3},
    _7_9euclidean = {type = "euclidean", pulses = 7, steps = 9, group = 3},
    _7_10euclidean = {type = "euclidean", pulses = 7, steps = 10, group = 3},
    _7_11euclidean = {type = "euclidean", pulses = 7, steps = 11, group = 3},
    _7_12euclidean = {type = "euclidean", pulses = 7, steps = 12, group = 3},
    _8_9euclidean = {type = "euclidean", pulses = 8, steps = 9, group = 3},
    _8_10euclidean = {type = "euclidean", pulses = 8, steps = 10, group = 3},
    _8_11euclidean = {type = "euclidean", pulses = 8, steps = 11, group = 3},
    _9_10euclidean = {type = "euclidean", pulses = 9, steps = 10, group = 3},
    _9_11euclidean = {type = "euclidean", pulses = 9, steps = 11, group = 3},
    _9_12euclidean = {type = "euclidean", pulses = 9, steps = 12, group = 3},
    
    -- Euclidean patterns - Group 4
    _10_11euclidean = {type = "euclidean", pulses = 10, steps = 11, group = 4},
    _10_12euclidean = {type = "euclidean", pulses = 10, steps = 12, group = 4},
    _11_11euclidean = {type = "euclidean", pulses = 11, steps = 11, group = 4},
    _11_12euclidean = {type = "euclidean", pulses = 11, steps = 12, group = 4},

    -- Shuffle patterns
    basic_snare_hat_shuffle = {type = "shuffle", name = "Basic Snare Hat"},
    syncopated_ghost_shuffle = {type = "shuffle", name = "Syncopated Ghost"},
    hat_driven_shuffle = {type = "shuffle", name = "Hat Driven"},
    complex_shuffle = {type = "shuffle", name = "Complex"},
    triplet_feel_shuffle = {type = "shuffle", name = "Triplet Feel"},
    kick_hat_shuffle = {type = "shuffle", name = "Basic Kick Hat"},
    syncopated_kick_shuffle = {type = "shuffle", name = "Syncopated Kick"},
    ghost_kick_shuffle = {type = "shuffle", name = "Ghost Kick"},
    rolling_hat_shuffle = {type = "shuffle", name = "Rolling Hat"},
    interplay_shuffle = {type = "shuffle", name = "Kick Hat Interplay"},
    two_step_shuffle = {type = "shuffle", name = "Two Step"},
    syncopated_kick_snare_shuffle = {type = "shuffle", name = "Syncopated Kick Snare"},
    rolling_snare_shuffle = {type = "shuffle", name = "Rolling Snare"},
    complex_kick_shuffle = {type = "shuffle", name = "Complex Kick"},
    ghost_groove_shuffle = {type = "shuffle", name = "Ghost Groove"}
    
}

-- Helper function to get templates by type
function templates.get_by_type(pattern_type)
    local result = {}
    for name, data in pairs(templates) do
        if name ~= "metadata" and 
           name ~= "get_by_type" and 
           name ~= "get_beat_patterns" and 
           name ~= "get_euclidean_patterns" and 
           name ~= "get_extras_patterns" and 
           name ~= "get_multi_patterns" and 
           name ~= "get_shuffle_patterns" and
           templates.metadata[name] and 
           templates.metadata[name].type == pattern_type then
            result[name] = data
        end
    end
    return result
end

-- Helper function to get beat patterns by selected genres
function templates.get_beat_patterns(selected_genres)
    local result = {}
    for name, data in pairs(templates) do
        local meta = templates.metadata[name]
        if meta and meta.type == "beat" and selected_genres[meta.genre] then
            result[name] = data
        end
    end
    return result
end

-- Helper function to get euclidean patterns by pulse/step ranges
function templates.get_euclidean_patterns(pulse_min, pulse_max, step_min, step_max)
    local result = {}
    for name, data in pairs(templates) do
        local meta = templates.metadata[name]
        if meta and meta.type == "euclidean" and 
           meta.pulses >= pulse_min and meta.pulses <= pulse_max and
           meta.steps >= step_min and meta.steps <= step_max then
            result[name] = data
        end
    end
    return result
end

-- Helper function to get extras patterns by category
function templates.get_extras_patterns(selected_categories)
    local result = {}
    for name, data in pairs(templates) do
        local meta = templates.metadata[name]
        if meta and meta.type == "extras" and selected_categories[meta.category] then
            result[name] = data
        end
    end
    return result
end

-- Helper function to get multi patterns (always returns all since they don't have subcategories)
function templates.get_multi_patterns()
    return templates.get_by_type("multi")
end

-- Helper function to get shuffle patterns by selected types
function templates.get_shuffle_patterns(selected_types)
    local result = {}
    for name, data in pairs(templates) do
        local meta = templates.metadata[name]
        if meta and meta.type == "shuffle" and selected_types[name] then
            result[name] = data
        end
    end
    return result
end


return templates
