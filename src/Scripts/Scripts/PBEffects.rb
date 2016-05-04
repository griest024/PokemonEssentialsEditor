begin
  module PBEffects
    # These effects apply to a battler
    AquaRing          = 0
    Attract           = 1
    Bide              = 2
    BideDamage        = 3
    BideTarget        = 4
    Charge            = 5
    ChoiceBand        = 6
    Confusion         = 7
    Counter           = 8
    CounterTarget     = 9
    Curse             = 10
    DefenseCurl       = 11
    DestinyBond       = 12
    Disable           = 13
    DisableMove       = 14
    EchoedVoice       = 15
    Embargo           = 16
    Encore            = 17
    EncoreIndex       = 18
    EncoreMove        = 19
    Endure            = 20
    FlashFire         = 21
    Flinch            = 22
    FocusEnergy       = 23
    FollowMe          = 24
    Foresight         = 25
    FuryCutter        = 26
    FutureSight       = 27
    FutureSightDamage = 28
    FutureSightMove   = 29
    FutureSightUser   = 30
    GastroAcid        = 31
    Grudge            = 32
    HealBlock         = 33
    HealingWish       = 34
    HelpingHand       = 35
    HyperBeam         = 36
    Imprison          = 37
    Ingrain           = 38
    LeechSeed         = 39
    LockOn            = 40
    LockOnPos         = 41
    LunarDance        = 42
    MagicCoat         = 43
    MagnetRise        = 44
    MeanLook          = 45
    Metronome         = 46
    Minimize          = 47
    MiracleEye        = 48
    MirrorCoat        = 49
    MirrorCoatTarget  = 50
    MudSport          = 51
    MultiTurn         = 52 # Trapping move
    MultiTurnAttack   = 53
    MultiTurnUser     = 54
    Nightmare         = 55
    Outrage           = 56
    PerishSong        = 57
    PerishSongUser    = 58
    Pinch             = 59 # Battle Palace only
    PowerTrick        = 60
    Protect           = 61
    ProtectNegation   = 62
    ProtectRate       = 63
    Pursuit           = 64
    Rage              = 65
    Revenge           = 66
    Rollout           = 67
    Roost             = 68
    SkyDrop           = 69
    SmackDown         = 70
    Snatch            = 71
    Stockpile         = 72
    StockpileDef      = 73
    StockpileSpDef    = 74
    Substitute        = 75
    Taunt             = 76
    Telekinesis       = 77
    Torment           = 78
    Toxic             = 79
    Trace             = 80
    Transform         = 81
    Truant            = 82
    TwoTurnAttack     = 83
    Uproar            = 84
    WaterSport        = 85
    WeightMultiplier  = 86
    Wish              = 87
    WishAmount        = 88
    WishMaker         = 89
    Yawn              = 90
    # These effects apply to a side
    LightScreen = 0
    LuckyChant  = 1
    Mist        = 2
    Reflect     = 3
    Safeguard   = 4
    Spikes      = 5
    StealthRock = 6
    Tailwind    = 7
    ToxicSpikes = 8
    # These effects apply to the battle (i.e. both sides)
    Gravity    = 0
    MagicRoom  = 1
    #TrickRoom  = 2
    #WonderRoom = 3
    # These effects apply to the usage of a move
    SpecialUsage = 0
    PassedTrying = 1
    TotalDamage  = 2
  end

rescue Exception
  if $!.is_a?(SystemExit) || "#{$!.class}"=="Reset"
    raise $!
  end
end