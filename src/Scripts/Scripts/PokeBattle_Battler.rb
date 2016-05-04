class PokeBattle_Battler
  attr_reader :battle
  attr_reader :pokemon
  attr_reader :name
  attr_reader :index
  attr_reader :pokemonIndex
  attr_reader :totalhp
  attr_reader :fainted
  attr_reader :usingsubmove
  attr_accessor :lastAttacker
  attr_accessor :turncount
  attr_accessor :effects
  attr_accessor :species
  attr_accessor :type1
  attr_accessor :type2
  attr_accessor :ability
  attr_accessor :gender
  attr_accessor :attack
  attr_accessor :defense
  attr_accessor :spatk
  attr_accessor :spdef
  attr_accessor :speed
  attr_accessor :stages
  attr_accessor :iv
  attr_accessor :moves
  attr_accessor :participants
  attr_accessor :lastHPLost
  attr_accessor :lastMoveUsed
  attr_accessor :lastMoveUsedSketch
  attr_accessor :lastRegularMoveUsed
  attr_accessor :lastRoundMoved
  attr_accessor :movesUsed
  attr_accessor :currentMove
  attr_accessor :damagestate

  def inHyperMode?; return false; end
  def isShadow?; return false; end

################################################################################
# Complex accessors
################################################################################
  def nature
    return (@pokemon) ? @pokemon.nature : 0
  end

  def happiness
    return (@pokemon) ? @pokemon.happiness : 0
  end

  def pokerusStage
    return (@pokemon) ? @pokemon.pokerusStage : 0
  end

  attr_reader :form

  def form=(value)
    @form=value
    @pokemon.form=value if @pokemon
  end

  def hasMega?
    if @pokemon
      return (@pokemon.hasMegaForm? rescue false)
    end
    return false
  end

  def isMega?
    if @pokemon
      return (@pokemon.isMega? rescue false)
    end
    return false
  end

  attr_reader :level

  def level=(value)
    @level=value
    @pokemon.level=(value) if @pokemon
  end

  attr_reader :status

  def status=(value)
    if @status==PBStatuses::SLEEP && value==0
      @effects[PBEffects::Truant]=false
    end
    @status=value
    @pokemon.status=value if @pokemon
    if value!=PBStatuses::POISON
      @effects[PBEffects::Toxic]=0
    end
    if value!=PBStatuses::POISON && value!=PBStatuses::SLEEP
      @statusCount=0
      @pokemon.statusCount=0 if @pokemon
    end
  end

  attr_reader :statusCount

  def statusCount=(value)
    @statusCount=value
    @pokemon.statusCount=value if @pokemon
  end

  attr_reader :hp

  def hp=(value)
    @hp=value.to_i
    @pokemon.hp=value.to_i if @pokemon
  end

  attr_reader :item

  def item=(value)
    @item=value
    @pokemon.setItem(value) if @pokemon
  end

  def weight
    w=(@pokemon) ? @pokemon.weight : 500
    w*=2 if self.hasWorkingAbility(:HEAVYMETAL)
    w/=2 if self.hasWorkingAbility(:LIGHTMETAL)
    w/=2 if self.hasWorkingItem(:FLOATSTONE)
    w*=@effects[PBEffects::WeightMultiplier]
    w=1 if w<1
    return w
  end

  def owned
    return (@pokemon) ? $Trainer.owned[@pokemon.species] && !@battle.opponent : false
  end

################################################################################
# Creating a battler
################################################################################
  def initialize(btl,index)
    @battle       = btl
    @index        = index
    @hp           = 0
    @totalhp      = 0
    @fainted      = true
    @usingsubmove = false
    @stages       = []
    @effects      = []
    @damagestate  = PokeBattle_DamageState.new
    pbInitBlank
    pbInitEffects(false)
    pbInitPermanentEffects
  end

  def pbInitPokemon(pkmn,pkmnIndex)
    if pkmn.isEgg?
      raise _INTL("An egg can't be an active Pokémon")
    end
    @name         = pkmn.name
    @species      = pkmn.species
    @level        = pkmn.level
    @hp           = pkmn.hp
    @totalhp      = pkmn.totalhp
    @gender       = pkmn.gender
    @ability      = pkmn.ability
    @type1        = pkmn.type1
    @type2        = pkmn.type2
    @form         = pkmn.form
    @attack       = pkmn.attack
    @defense      = pkmn.defense
    @speed        = pkmn.speed
    @spatk        = pkmn.spatk
    @spdef        = pkmn.spdef
    @status       = pkmn.status
    @statusCount  = pkmn.statusCount
    @pokemon      = pkmn
    @pokemonIndex = pkmnIndex
    @participants = [] # Participants will earn Exp. Points if this battler is defeated
    @moves        = [
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[0]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[1]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[2]),
       PokeBattle_Move.pbFromPBMove(@battle,pkmn.moves[3])
    ]
    @iv           = []
    @iv[0]        = pkmn.iv[0]
    @iv[1]        = pkmn.iv[1]
    @iv[2]        = pkmn.iv[2]
    @iv[3]        = pkmn.iv[3]
    @iv[4]        = pkmn.iv[4]
    @iv[5]        = pkmn.iv[5]
    @item         = pkmn.item
  end

  def pbInitBlank
    @name         = ""
    @species      = 0
    @level        = 0
    @hp           = 0
    @totalhp      = 0
    @gender       = 0
    @ability      = 0
    @type1        = 0
    @type2        = 0
    @form         = 0
    @attack       = 0
    @defense      = 0
    @speed        = 0
    @spatk        = 0
    @spdef        = 0
    @status       = 0
    @statusCount  = 0
    @pokemon      = nil
    @pokemonIndex = -1
    @participants = []
    @moves        = [nil,nil,nil,nil]
    @iv           = [0,0,0,0,0,0]
    @item         = 0
    @weight       = nil
  end

  def pbInitPermanentEffects
    # These effects are always retained even if a Pokémon is replaced
    @effects[PBEffects::FutureSight]       = 0
    @effects[PBEffects::FutureSightDamage] = 0
    @effects[PBEffects::FutureSightMove]   = 0
    @effects[PBEffects::FutureSightUser]   = -1
    @effects[PBEffects::HealingWish]       = false
    @effects[PBEffects::LunarDance]        = false
    @effects[PBEffects::Wish]              = 0
    @effects[PBEffects::WishAmount]        = 0
    @effects[PBEffects::WishMaker]         = -1
  end

  def pbInitEffects(batonpass)
    if !batonpass
      # These effects are retained if Baton Pass is used
      @stages[PBStats::ATTACK]   = 0
      @stages[PBStats::DEFENSE]  = 0
      @stages[PBStats::SPEED]    = 0
      @stages[PBStats::SPATK]    = 0
      @stages[PBStats::SPDEF]    = 0
      @stages[PBStats::EVASION]  = 0
      @stages[PBStats::ACCURACY] = 0
      @lastMoveUsedSketch        = -1
      @effects[PBEffects::AquaRing]    = false
      @effects[PBEffects::Confusion]   = 0
      @effects[PBEffects::Curse]       = false
      @effects[PBEffects::Embargo]     = 0
      @effects[PBEffects::FocusEnergy] = 0
      @effects[PBEffects::GastroAcid]  = false
      @effects[PBEffects::HealBlock]   = 0
      @effects[PBEffects::Ingrain]     = false
      @effects[PBEffects::LeechSeed]   = -1
      @effects[PBEffects::LockOn]      = 0
      @effects[PBEffects::LockOnPos]   = -1
      for i in 0...4
        next if !@battle.battlers[i]
        if @battle.battlers[i].effects[PBEffects::LockOnPos]==@index &&
           @battle.battlers[i].effects[PBEffects::LockOn]>0
          @battle.battlers[i].effects[PBEffects::LockOn]=0
          @battle.battlers[i].effects[PBEffects::LockOnPos]=-1
        end
      end
      @effects[PBEffects::MagnetRise]     = 0
      @effects[PBEffects::PerishSong]     = 0
      @effects[PBEffects::PerishSongUser] = -1
      @effects[PBEffects::PowerTrick]     = false
      @effects[PBEffects::Substitute]     = 0
      @effects[PBEffects::Telekinesis]    = 0
    else
      if @effects[PBEffects::LockOn]>0
        @effects[PBEffects::LockOn]=2
      else
        @effects[PBEffects::LockOn]=0
      end
      if @effects[PBEffects::PowerTrick]
        s=@attack
        @attack=@defense
        @defense=a
      end
    end
    @damagestate.reset
    @fainted        = false
    @lastAttacker   = -1
    @lastHPLost     = 0
    @lastMoveUsed   = -1
    @lastRoundMoved = -1
    @movesUsed      = []
    @turncount      = 0
    @effects[PBEffects::Attract]          = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::Attract]==@index
        @battle.battlers[i].effects[PBEffects::Attract]=-1
      end
    end
    @effects[PBEffects::Bide]             = 0
    @effects[PBEffects::BideDamage]       = 0
    @effects[PBEffects::BideTarget]       = -1
    @effects[PBEffects::Charge]           = 0
    @effects[PBEffects::ChoiceBand]       = -1
    @effects[PBEffects::Counter]          = -1
    @effects[PBEffects::CounterTarget]    = -1
    @effects[PBEffects::DefenseCurl]      = false
    @effects[PBEffects::DestinyBond]      = false
    @effects[PBEffects::Disable]          = 0
    @effects[PBEffects::DisableMove]      = 0
    @effects[PBEffects::EchoedVoice]      = 0
    @effects[PBEffects::Encore]           = 0
    @effects[PBEffects::EncoreIndex]      = 0
    @effects[PBEffects::EncoreMove]       = 0
    @effects[PBEffects::Endure]           = false
    @effects[PBEffects::FlashFire]        = false
    @effects[PBEffects::Flinch]           = false
    @effects[PBEffects::FollowMe]         = false
    @effects[PBEffects::Foresight]        = false
    @effects[PBEffects::FuryCutter]       = 0
    @effects[PBEffects::Grudge]           = false
    @effects[PBEffects::HelpingHand]      = false
    @effects[PBEffects::HyperBeam]        = 0
    @effects[PBEffects::Imprison]         = false
    @effects[PBEffects::MagicCoat]        = false
    @effects[PBEffects::MeanLook]         = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MeanLook]==@index
        @battle.battlers[i].effects[PBEffects::MeanLook]=-1
      end
    end
    @effects[PBEffects::Metronome]        = 0
    @effects[PBEffects::Minimize]         = false
    @effects[PBEffects::MiracleEye]       = false
    @effects[PBEffects::MirrorCoat]       = -1
    @effects[PBEffects::MirrorCoatTarget] = -1
    @effects[PBEffects::MudSport]         = false
    @effects[PBEffects::MultiTurn]        = 0
    @effects[PBEffects::MultiTurnAttack]  = 0
    @effects[PBEffects::MultiTurnUser]    = -1
    for i in 0...4
      next if !@battle.battlers[i]
      if @battle.battlers[i].effects[PBEffects::MultiTurnUser]==@index
        @battle.battlers[i].effects[PBEffects::MultiTurn]=0
        @battle.battlers[i].effects[PBEffects::MultiTurnUser]=-1
      end
    end
    @effects[PBEffects::Nightmare]        = false
    @effects[PBEffects::Outrage]          = 0
    @effects[PBEffects::Pinch]            = false
    @effects[PBEffects::Protect]          = false
    @effects[PBEffects::ProtectNegation]  = false
    @effects[PBEffects::ProtectRate]      = 1
    @effects[PBEffects::Pursuit]          = false
    @effects[PBEffects::Rage]             = false
    @effects[PBEffects::Revenge]          = 0
    @effects[PBEffects::Rollout]          = 0
    @effects[PBEffects::Roost]            = false
    @effects[PBEffects::SkyDrop]          = false
    @effects[PBEffects::SmackDown]        = false
    @effects[PBEffects::Snatch]           = false
    @effects[PBEffects::Stockpile]        = 0
    @effects[PBEffects::StockpileDef]     = 0
    @effects[PBEffects::StockpileSpDef]   = 0
    @effects[PBEffects::Taunt]            = 0
    @effects[PBEffects::Torment]          = false
    @effects[PBEffects::Toxic]            = 0
    @effects[PBEffects::Trace]            = false
    @effects[PBEffects::Transform]        = false
    @effects[PBEffects::Truant]           = false
    @effects[PBEffects::TwoTurnAttack]    = 0
    @effects[PBEffects::Uproar]           = 0
    @effects[PBEffects::WaterSport]       = false
    @effects[PBEffects::WeightMultiplier] = 1.0
    @effects[PBEffects::Yawn]             = 0
  end

  def pbUpdate(fullchange=false)
    if @pokemon
      @pokemon.calcStats
      @level     = @pokemon.level
      @hp        = @pokemon.hp
      @totalhp   = @pokemon.totalhp
      if !@effects[PBEffects::Transform]
        @attack    = @pokemon.attack
        @defense   = @pokemon.defense
        @speed     = @pokemon.speed
        @spatk     = @pokemon.spatk
        @spdef     = @pokemon.spdef
        if fullchange
          @ability = @pokemon.ability
          @type1   = @pokemon.type1
          @type2   = @pokemon.type2
        end
      end
    end
  end

  def pbInitialize(pkmn,index,batonpass)
    # Cure status of previous Pokemon with Natural Cure
    if self.hasWorkingAbility(:NATURALCURE) && @pokemon
      self.status=0
    end
    if self.hasWorkingAbility(:REGENERATOR) && @pokemon
      self.pbRecoverHP((totalhp/3).floor,true)
    end
    pbInitPokemon(pkmn,index)
    pbInitEffects(batonpass)
  end

# Used only to erase the battler of a Shadow Pokémon that has been snagged.
  def pbReset
    @pokemon                = nil
    @pokemonIndex           = -1
    self.hp                 = 0
    pbInitEffects(false)
    # reset status
    self.status             = 0
    self.statusCount        = 0
    @fainted                = true
    # reset choice
    @battle.choices[@index] = [0,0,nil,-1]
    return true
  end

# Update Pokémon who will gain EXP if this battler is defeated
  def pbUpdateParticipants
    return if self.isFainted? # can't update if already fainted
    if @battle.pbIsOpposing?(@index)
      found1=false
      found2=false
      for i in @participants
        found1=true if i==pbOpposing1.pokemonIndex
        found2=true if i==pbOpposing2.pokemonIndex
      end
      if !found1 && !pbOpposing1.isFainted?
        @participants[@participants.length]=pbOpposing1.pokemonIndex
      end
      if !found2 && !pbOpposing2.isFainted?
        @participants[@participants.length]=pbOpposing2.pokemonIndex
      end
    end
  end

################################################################################
# About this battler
################################################################################
  def pbThis(lowercase=false)
    if @battle.pbIsOpposing?(@index)
      if @battle.opponent
        return lowercase ? _INTL("the foe {1}",@name) : _INTL("The foe {1}",@name)
      else
        return lowercase ? _INTL("the wild {1}",@name) : _INTL("The wild {1}",@name)
      end
    elsif @battle.pbOwnedByPlayer?(@index)
      return _INTL("{1}",@name)
    else
      return lowercase ? _INTL("the ally {1}",@name) : _INTL("The ally {1}",@name)
    end
  end

  def pbHasType?(type)
    if type.is_a?(Symbol) || type.is_a?(String)
      ret=isConst?(self.type1,PBTypes,type.to_sym) ||
          isConst?(self.type2,PBTypes,type.to_sym)
      return ret
    else
      return (self.type1==type || self.type2==type)
    end
  end
  
  def pbHasMove?(id)
    if id.is_a?(String) || id.is_a?(Symbol)
      id=getID(PBMoves,id)
    end
    return false if !id || id==0
    for i in @moves
      return true if i.id==id
    end
    return false
  end

  def pbHasMoveFunction?(code)
    return false if !code
    for i in @moves
      return true if i.function==code
    end
    return false
  end

  def hasMovedThisRound?
    return false if !@lastRoundMoved
    return @lastRoundMoved==@battle.turncount
  end

  def isFainted?
    return @hp<=0
  end

  def hasWorkingAbility(ability,ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::GastroAcid]
    return isConst?(@ability,PBAbilities,ability)
  end

  def hasWorkingItem(item,ignorefainted=false)
    return false if self.isFainted? if !ignorefainted
    return false if @effects[PBEffects::Embargo]>0
    return false if @battle.field.effects[PBEffects::MagicRoom]>0
    return false if self.hasWorkingAbility(:KLUTZ,ignorefainted)
    return isConst?(@item,PBItems,item)
  end

  def isAirborne?
    return false if self.hasWorkingItem(:IRONBALL)
    return false if @effects[PBEffects::Ingrain]
    return false if @effects[PBEffects::SmackDown]
    return false if @battle.field.effects[PBEffects::Gravity]>0
    return true if self.pbHasType?(:FLYING)
    return true if self.hasWorkingAbility(:LEVITATE)
    return true if self.hasWorkingItem(:AIRBALLOON)
    return true if @effects[PBEffects::MagnetRise]>0
    return true if @effects[PBEffects::Telekinesis]>0
    return false
  end

  def pbSpeed()
    stagemul=[10,10,10,10,10,10,10,15,20,25,30,35,40]
    stagediv=[40,35,30,25,20,15,10,10,10,10,10,10,10]
    speed=@speed
    stage=@stages[PBStats::SPEED]+6
    speed=(speed*stagemul[stage]/stagediv[stage]).floor
    if self.pbOwnSide.effects[PBEffects::Tailwind]>0
      speed=speed*2
    end
    if self.hasWorkingAbility(:SWIFTSWIM) && @battle.pbWeather==PBWeather::RAINDANCE
      speed=speed*2
    end
    if self.hasWorkingAbility(:CHLOROPHYLL) && @battle.pbWeather==PBWeather::SUNNYDAY
      speed=speed*2
    end
    if self.hasWorkingAbility(:SANDRUSH) && @battle.pbWeather==PBWeather::SANDSTORM
      speed=speed*2
    end
    if self.hasWorkingAbility(:QUICKFEET) && self.status>0
      speed=(speed*1.5).floor
    end
    if self.hasWorkingItem(:MACHOBRACE) ||
       self.hasWorkingItem(:POWERWEIGHT) ||
       self.hasWorkingItem(:POWERBRACER) ||
       self.hasWorkingItem(:POWERBELT) ||
       self.hasWorkingItem(:POWERANKLET) ||
       self.hasWorkingItem(:POWERLENS) ||
       self.hasWorkingItem(:POWERBAND)
      speed=(speed/2).floor
    end
    if self.hasWorkingItem(:CHOICESCARF)
      speed=(speed*1.5).floor
    end
    if isConst?(self.item,PBItems,:IRONBALL)
      speed=(speed/2).floor
    end
    if isConst?(self.species,PBSpecies,:DITTO) && !@effects[PBEffects::Transform] &&
       self.hasWorkingItem(:QUICKPOWDER)
      speed=speed*2
    end
    if self.hasWorkingAbility(:SLOWSTART) && self.turncount<=5
      speed=(speed/2).floor
    end
    if self.status==PBStatuses::PARALYSIS && !self.hasWorkingAbility(:QUICKFEET)
      speed=(speed/4).floor
    end
    if @battle.internalbattle && @battle.pbOwnedByPlayer?(@index)
      speed=(speed*1.1).floor if @battle.pbPlayer.numbadges>=BADGESBOOSTSPEED
    end
    return speed
  end

################################################################################
# Change HP
################################################################################
  def pbReduceHP(amt,anim=false)
    if amt>=self.hp
      amt=self.hp
    elsif amt<=0 && !self.isFainted?
      amt=1
    end
    oldhp=self.hp
    self.hp-=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    return amt
  end

  def pbRecoverHP(amt,anim=false)
    if self.hp+amt>@totalhp
      amt=@totalhp-self.hp
    elsif amt<=0 && self.hp!=@totalhp
      amt=1
    end
    oldhp=self.hp
    self.hp+=amt
    raise _INTL("HP less than 0") if self.hp<0
    raise _INTL("HP greater than total HP") if self.hp>@totalhp
    @battle.scene.pbHPChanged(self,oldhp,anim) if amt>0
    return amt
  end

  def pbFaint(showMessage=true)
    if !self.isFainted?
      PBDebug.log("!!!***Can't faint with HP greater than 0")
      return true
    end
    if @fainted
#      PBDebug.log("!!!***Can't faint if already fainted")
      return true
    end
    @battle.scene.pbFainted(self)
    pbInitEffects(false)
    # reset status
    self.status=0
    self.statusCount=0
    if @pokemon && @battle.internalbattle
      @pokemon.changeHappiness("faint")
    end
    @fainted=true
    # reset choice
    @battle.choices[@index]=[0,0,nil,-1]
    @battle.pbDisplayPaused(_INTL("{1} fainted!",pbThis)) if showMessage
    PBDebug.log("[#{pbThis} fainted]")
    return true
  end

################################################################################
# Find other battlers/sides in relation to this battler
################################################################################
# Returns the data structure for this battler's side
  def pbOwnSide
    return @battle.sides[index&1] # Player: 0 and 2; Foe: 1 and 3
  end

# Returns the data structure for the opposing Pokémon's side
  def pbOpposingSide
    return @battle.sides[(index&1)^1] # Player: 1 and 3; Foe: 0 and 2
  end

# Returns whether the position belongs to the opposing Pokémon's side
  def pbIsOpposing?(i)
    return (@index&1)!=(i&1)
  end

# Returns the battler's partner
  def pbPartner
    return @battle.battlers[(@index&1)|((@index&2)^2)]
  end

# Returns the battler's first opposing Pokémon
  def pbOpposing1
    return @battle.battlers[((@index&1)^1)]
  end

# Returns the battler's second opposing Pokémon
  def pbOpposing2
    return @battle.battlers[((@index&1)^1)+2]
  end

  def pbOppositeOpposing
    return @battle.battlers[(@index^1)]
  end

  def pbOppositeOpposing2
    return @battle.battlers[(@index^1)|((@index&2)^2)]
  end

  def pbNonActivePokemonCount()
    count=0
    party=@battle.pbParty(self.index)
    for i in 0...party.length
      if (self.isFainted? || i!=self.pokemonIndex) &&
         (pbPartner.isFainted? || i!=self.pbPartner.pokemonIndex) &&
         party[i] && !party[i].isEgg? && party[i].hp>0
        count+=1
      end
    end
    return count
  end

################################################################################
# Forms
################################################################################
  def pbCheckForm
    return if @effects[PBEffects::Transform]
    transformed=false
    # Forecast
    if self.hasWorkingAbility(:FORECAST) && isConst?(self.species,PBSpecies,:CASTFORM)
      case @battle.pbWeather
      when PBWeather::SUNNYDAY
        if self.form!=1
          self.form=1
          transformed=true
        end
      when PBWeather::RAINDANCE
        if self.form!=2
          self.form=2
          transformed=true
        end
      when PBWeather::HAIL
        if self.form!=3
          self.form=3
          transformed=true
        end
      else
        if self.form!=0
          self.form=0
          transformed=true
        end
      end
      showmessage=transformed
    end
    # Cherrim
    if isConst?(self.species,PBSpecies,:CHERRIM) && !self.isFainted?
      case @battle.pbWeather
      when PBWeather::SUNNYDAY
        if self.form!=1
          self.form=1
          transformed=true
        end
      else
        if self.form!=0
          self.form=0
          transformed=true
        end
      end
    end
    # Shaymin
    if isConst?(self.species,PBSpecies,:SHAYMIN) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Giratina
    if isConst?(self.species,PBSpecies,:GIRATINA) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Arceus
    if isConst?(self.ability,PBAbilities,:MULTITYPE) &&
       isConst?(self.species,PBSpecies,:ARCEUS) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Zen Mode
    if isConst?(self.species,PBSpecies,:DARMANITAN) && !self.isFainted?
      if self.hasWorkingAbility(:ZENMODE)
        if @hp<=((@totalhp/2).floor)
          if self.form!=1
            self.form=1; transformed=true
          end
        else
          if self.form!=0
            self.form=0; transformed=true
          end
        end
      else
        if self.form!=0
          self.form=0; transformed=true
        end
      end
    end
    # Keldeo
    if isConst?(self.species,PBSpecies,:KELDEO) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    # Genesect
    if isConst?(self.species,PBSpecies,:GENESECT) && !self.isFainted?
      if self.form!=@pokemon.form
        self.form=@pokemon.form
        transformed=true
      end
    end
    if transformed
      pbUpdate(true)
      @battle.scene.pbChangePokemon(self,@pokemon)
      @battle.pbDisplay(_INTL("{1} transformed!",pbThis))
      PBDebug.log("[#{pbThis}: form changed (now #{self.form})]")
    end
  end

  def pbResetForm
    if !@effects[PBEffects::Transform]
      if isConst?(self.species,PBSpecies,:CASTFORM) ||
         isConst?(self.species,PBSpecies,:CHERRIM) ||
         isConst?(self.species,PBSpecies,:DARMANITAN) ||
         isConst?(self.species,PBSpecies,:MELOETTA)
        self.form=0
      end
    end
    pbUpdate(true)
  end

################################################################################
# Ability effects
################################################################################
  def pbAbilitiesOnSwitchIn(onactive)
    return if self.isFainted?
    # Weather
    if onactive
      if self.hasWorkingAbility(:DRIZZLE) && battle.weather!=PBWeather::RAINDANCE && @battle.weatherduration!=-1
        @battle.weather=PBWeather::RAINDANCE
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("Rain",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drizzle made it rain!",pbThis))
        PBDebug.log("[#{pbThis}: Drizzle made it rain]")
      end
      if self.hasWorkingAbility(:SANDSTREAM) && @battle.weather!=PBWeather::SANDSTORM && @battle.weatherduration!=-1
        @battle.weather=PBWeather::SANDSTORM
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("Sandstorm",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Sand Stream whipped up a sandstorm!",pbThis))
        PBDebug.log("[#{pbThis}: Sand Stream made it sandstorm]")
      end
      if self.hasWorkingAbility(:DROUGHT) && @battle.weather!=PBWeather::SUNNYDAY && @battle.weatherduration!=-1
        @battle.weather=PBWeather::SUNNYDAY
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("Sunny",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Drought intensified the sun's rays!",pbThis))
        PBDebug.log("[#{pbThis}: Drought made it sunny]")
      end
      if self.hasWorkingAbility(:SNOWWARNING) && @battle.weather!=PBWeather::HAIL && @battle.weatherduration!=-1
        @battle.weather=PBWeather::HAIL
        @battle.weatherduration=-1
        @battle.pbCommonAnimation("Hail",nil,nil)
        @battle.pbDisplay(_INTL("{1}'s Snow Warning made it hail!",pbThis))
        PBDebug.log("[#{pbThis}: Snow Warning made it hail]")
      end
      if self.hasWorkingAbility(:AIRLOCK)
        @battle.pbDisplay(_INTL("{1} has Air Lock!",pbThis))
        PBDebug.log("[#{pbThis}: has Air Lock]")
      elsif self.hasWorkingAbility(:CLOUDNINE)
        @battle.pbDisplay(_INTL("The effects of weather disappeared."))
        PBDebug.log("[#{pbThis}: has Cloud Nine]")
      end
    end
    # Pressure message
    if self.hasWorkingAbility(:PRESSURE) && onactive
      @battle.pbDisplay(_INTL("{1} is exerting its Pressure!",pbThis))
      PBDebug.log("[#{pbThis}: has Pressure]")
    end
    # Trace
    if self.hasWorkingAbility(:TRACE)
      if @effects[PBEffects::Trace] || onactive
        choices=[]
        for i in 0...4
          if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
            choices[choices.length]=i if @battle.battlers[i].ability!=0 &&
               !isConst?(@battle.battlers[i].ability,PBAbilities,:MULTITYPE)
          end
        end
        if choices.length==0
          @effects[PBEffects::Trace]=true
        else
          choice=choices[@battle.pbRandom(choices.length)]
          battlername=@battle.battlers[choice].pbThis(true)
          battlerability=@battle.battlers[choice].ability
          @ability=battlerability
          abilityname=PBAbilities.getName(battlerability)
          @battle.pbDisplay(_INTL("{1} traced {2}'s {3}!",pbThis,battlername,abilityname))
          @effects[PBEffects::Trace]=false
          PBDebug.log(sprintf("[%s: traced ability %s from %s]",pbThis,abilityname,battlername))
        end
      end
    end
    # Intimidate
    if self.hasWorkingAbility(:INTIMIDATE) && onactive
      PBDebug.log("[#{pbThis}: has Intimidate]")
      for i in 0...4
        if pbIsOpposing?(i) && !@battle.battlers[i].isFainted?
          @battle.battlers[i].pbReduceAttackStatStageIntimidate(self)
        end
      end
    end
    # Download
    if self.hasWorkingAbility(:DOWNLOAD) && onactive
      PBDebug.log("[#{pbThis}: has Download]")
      odef=ospdef=0
      odef+=pbOpposing1.defense if !pbOpposing1.isFainted?
      ospdef+=pbOpposing1.spdef if !pbOpposing1.isFainted?
      if pbOpposing2
        odef+=pbOpposing2.defense if !pbOpposing2.isFainted?
        ospdef+=pbOpposing1.spdef if !pbOpposing2.isFainted?
      end
      if ospdef>odef
        if !pbTooHigh?(PBStats::ATTACK)
          pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Attack!",
             pbThis,PBAbilities.getName(ability)))
        end
      else
        if !pbTooHigh?(PBStats::SPATK)
          pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbDisplay(_INTL("{1}'s {2} boosted its Special Attack!",
             pbThis,PBAbilities.getName(ability)))
        end
      end
    end
    # Frisk
    if self.hasWorkingAbility(:FRISK) && @battle.pbOwnedByPlayer?(@index) && onactive
      PBDebug.log("[#{pbThis}: has Frisk]")
      items=[]
      items.push(pbOpposing1.item) if pbOpposing1.item>0 && !pbOpposing1.isFainted?
      items.push(pbOpposing2.item) if pbOpposing2.item>0 && !pbOpposing2.isFainted?
      if items.length>0
        item=items[@battle.pbRandom(items.length)]
        itemname=PBItems.getName(item)
        @battle.pbDisplay(_INTL("{1} frisked the foe and found one {2}!",pbThis,itemname))
      end
    end
    # Anticipation
    if self.hasWorkingAbility(:ANTICIPATION) && @battle.pbOwnedByPlayer?(@index) && onactive
      PBDebug.log("[#{pbThis}: has Anticipation]")
      found=false
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          eff=PBTypes.getCombinedEffectiveness(movedata.type,type1,type2)
          if (movedata.basedamage>0 && eff>4 &&
             movedata.function!=0x71 && # Counter
             movedata.function!=0x72 && # Mirror Coat
             movedata.function!=0x73) || # Metal Burst
             (movedata.function==0x70 && eff>0) # OHKO
            found=true
            break
          end
        end
        break if found
      end
      @battle.pbDisplay(_INTL("{1} shuddered with anticipation!",pbThis)) if found
    end
    # Forewarn
    if self.hasWorkingAbility(:FOREWARN) && @battle.pbOwnedByPlayer?(@index) && onactive
      PBDebug.log("[#{pbThis}: has Forewarn]")
      highpower=0
      moves=[]
      for foe in [pbOpposing1,pbOpposing2]
        next if foe.isFainted?
        for j in foe.moves
          movedata=PBMoveData.new(j.id)
          power=movedata.basedamage
          power=160 if movedata.function==0x70    # OHKO
          power=150 if movedata.function==0x8B    # Eruption
          power=120 if movedata.function==0x71 || # Counter
                       movedata.function==0x72 || # Mirror Coat
                       movedata.function==0x73 || # Metal Burst
          power=80 if movedata.function==0x6A ||  # SonicBoom
                      movedata.function==0x6B ||  # Dragon Rage
                      movedata.function==0x6D ||  # Night Shade
                      movedata.function==0x6E ||  # Endeavor
                      movedata.function==0x6F ||  # Psywave
                      movedata.function==0x89 ||  # Return
                      movedata.function==0x8A ||  # Frustration
                      movedata.function==0x8C ||  # Crush Grip
                      movedata.function==0x8D ||  # Gyro Ball
                      movedata.function==0x90 ||  # Hidden Power
                      movedata.function==0x96 ||  # Natural Gift
                      movedata.function==0x97 ||  # Trump Card
                      movedata.function==0x98 ||  # Flail
                      movedata.function==0x9A     # Grass Knot
          if power>highpower
            moves=[j.id]; highpower=power
          elsif power==highpower
            moves.push(j.id)
          end
        end
      end
      if moves.length>0
        move=moves[@battle.pbRandom(moves.length)]
        movename=PBMoves.getName(move)
        @battle.pbDisplay(_INTL("{1}'s Forewarn alerted it to {2}!",pbThis,movename))
      end
    end
    # Imposter
    if self.hasWorkingAbility(:IMPOSTER) && !@effects[PBEffects::Transform] && onactive
      PBDebug.log("[#{pbThis}: has Imposter]")
      choice=pbOppositeOpposing
      blacklist=[
         0xC9,    # Fly
         0xCA,    # Dig
         0xCB,    # Dive
         0xCC,    # Bounce
         0xCD,    # Shadow Force
         0xCE     # Sky Drop
      ]
      if choice.effects[PBEffects::Substitute]>0 ||
         choice.effects[PBEffects::Transform] ||
         choice.effects[PBEffects::SkyDrop] ||
         blacklist.include?(PBMoveData.new(choice.effects[PBEffects::TwoTurnAttack]).function)
        # Can't transform into chosen Pokémon, so forget it
      else
        @battle.pbAnimation(getConst(PBMoves,:TRANSFORM),self,choice)
        @effects[PBEffects::Transform]=true
        @species=choice.species
        @type1=choice.type1
        @type2=choice.type2
#        @ability=choice.ability
        @attack=choice.attack
        @defense=choice.defense
        @speed=choice.speed
        @spatk=choice.spatk
        @spdef=choice.spdef
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
                  PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
          @stages[i]=choice.stages[i]
        end
        for i in 0...4
          @moves[i]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(choice.moves[i].id))
          @moves[i].pp=5
          @moves[i].totalpp=5
        end
        @effects[PBEffects::Disable]=0
        @effects[PBEffects::DisableMove]=0
        @battle.pbDisplay(_INTL("{1} transformed into {2}!",pbThis,choice.pbThis(true)))
      end
    end
  end

  def pbEffectsOnDealingDamage(move,user,target,damage)
    movetype=move.pbType(move.type,user,target)
    if damage>0 && move.isContactMove?
      if !target.damagestate.substitute
        if target.hasWorkingItem(:STICKYBARB,true) && user.item==0 && !user.isFainted?
          user.item=target.item
          target.item=0
          if !@battle.opponent && !@battle.pbIsOpposing?(user.index)
            if user.pokemon.itemInitial==0 && target.pokemon.itemInitial==user.item
              user.pokemon.itemInitial=user.item
              target.pokemon.itemInitial=0
            end
          end
          @battle.pbDisplay(_INTL("{1}'s {2} was transferred to {3}!",
             target.pbThis,PBItems.getName(user.item),user.pbThis(true)))
          PBDebug.log("[Sticky Barb moved from #{target.pbThis(true)} to #{user.pbThis(true)}]")
        end
        if target.hasWorkingItem(:ROCKYHELMET,true) && !user.isFainted?
          PBDebug.log("[#{user.pbThis} hurt by Rocky Helmet]")
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/6).floor)
          @battle.pbDisplay(_INTL("{1} was hurt by the {2}!",user.pbThis,
             PBItems.getName(target.item)))
        end
        if target.hasWorkingAbility(:AFTERMATH,true) && !user.isFainted?
          if !pbCheckGlobalAbility(:DAMP)
            PBDebug.log("[#{user.pbThis} hurt by Aftermath]")
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP((user.totalhp/4).floor)
            @battle.pbDisplay(_INTL("{1} was caught in the aftermath!",user.pbThis))
          end
        end
        if target.hasWorkingAbility(:CUTECHARM) && @battle.pbRandom(10)<3
          if !user.hasWorkingAbility(:OBLIVIOUS) &&
             ((user.gender==1 && target.gender==0) ||
             (user.gender==0 && target.gender==1)) &&
             user.effects[PBEffects::Attract]<0 && !user.isFainted?
            user.effects[PBEffects::Attract]=target.index
            @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            PBDebug.log("[#{user.pbThis} was Cute Charmed by #{target.pbThis(true)}]")
            if user.hasWorkingItem(:DESTINYKNOT) &&
               !target.hasWorkingAbility(:OBLIVIOUS) &&
               target.effects[PBEffects::Attract]<0
              target.effects[PBEffects::Attract]=user.index
              @battle.pbDisplay(_INTL("{1}'s {2} infatuated {3}!",user.pbThis,
                 PBItems.getName(user.item),target.pbThis(true)))
              PBDebug.log("[#{user.pbThis}'s Destiny Knot infatuated #{target.pbThis(true)}]")
            end
          end
        end
        if target.hasWorkingAbility(:EFFECTSPORE,true) && @battle.pbRandom(10)<3
          PBDebug.log("[#{target.pbThis}'s Effect Spore triggered]")
          rnd=@battle.pbRandom(3)
          if rnd==0 && user.pbCanPoison?(false)
            user.pbPoison(target)
            @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif rnd==1 && user.pbCanSleep?(false)
            user.pbSleep
            @battle.pbDisplay(_INTL("{1}'s {2} made {3} sleep!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
          elsif rnd==2 && user.pbCanParalyze?(false)
            user.pbParalyze(target)
            @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
               target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
          end
        end
        if target.hasWorkingAbility(:FLAMEBODY,true) &&
           @battle.pbRandom(10)<3 && user.pbCanBurn?(false)
          PBDebug.log("[#{target.pbThis}'s Flame Body triggered]")
          user.pbBurn(target)
          @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:IRONBARBS,true) && !user.isFainted?
          PBDebug.log("[#{target.pbThis}'s Iron Barbs triggered]")
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/8).floor)
          @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:MUMMY,true) && !user.isFainted?
          if !isConst?(user.ability,PBAbilities,:MULTITYPE) &&
             !isConst?(user.ability,PBAbilities,:WONDERGUARD) &&
             !isConst?(user.ability,PBAbilities,:MUMMY)
            user.ability=getConst(PBAbilities,:MUMMY) || 0
            @battle.pbDisplay(_INTL("{1} was mummified by {2}!",
               user.pbThis,target.pbThis(true)))
            PBDebug.log("[#{user.pbThis}'s ability became Mummy by #{target.pbThis(true)}]")
          end
        end
        if target.hasWorkingAbility(:POISONPOINT,true) &&
           @battle.pbRandom(10)<3 && user.pbCanPoison?(false)
          PBDebug.log("[#{target.pbThis}'s Poison Point triggered]")
          user.pbPoison(target)
          @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:ROUGHSKIN,true) && !user.isFainted?
          PBDebug.log("[#{target.pbThis}'s Rough Skin triggered]")
          @battle.scene.pbDamageAnimation(user,0)
          user.pbReduceHP((user.totalhp/8).floor)
          @battle.pbDisplay(_INTL("{1}'s {2} hurt {3}!",target.pbThis,
             PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:STATIC,true) &&
           user.pbCanParalyze?(false) && @battle.pbRandom(10)<3
          PBDebug.log("[#{target.pbThis}'s Static triggered]")
          user.pbParalyze(target)
          @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
             target.pbThis,PBAbilities.getName(target.ability),user.pbThis(true)))
        end
        if target.hasWorkingAbility(:PICKPOCKET)
          if target.item==0 && user.item>0 &&
             user.effects[PBEffects::Substitute]==0 &&
             target.effects[PBEffects::Substitute]==0 &&
             !user.hasWorkingAbility(:STICKYHOLD) &&
             !@battle.pbIsUnlosableItem(user,user.item) &&
             !@battle.pbIsUnlosableItem(target,user.item) &&
             (@battle.opponent || !@battle.pbIsOpposing?(target.index))
            target.item=user.item
            user.item=0
            if !@battle.opponent &&   # In a wild battle
               target.pokemon.itemInitial==0 &&
               user.pokemon.itemInitial==target.item
              target.pokemon.itemInitial=target.item
              user.pokemon.itemInitial=0
            end
            @battle.pbDisplay(_INTL("{1} pickpocketed {2}'s {3}!",target.pbThis,
               user.pbThis(true),PBItems.getName(target.item)))
            PBDebug.log("[#{target.pbThis} Pickpocketed #{PBItems.getName(target.item)}) from #{user.pbThis(true)}]")
          end
        end
        # Gooey goes here
      end
      if user.hasWorkingAbility(:POISONTOUCH,true) &&
         @battle.pbRandom(10)<3 && target.pbCanPoison?(false)
        PBDebug.log("[#{user.pbThis}'s Poison Touch triggered]")
        target.pbPoison(user)
        @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",user.pbThis,
           PBAbilities.getName(user.ability),target.pbThis(true)))
      end
    end
    if damage>0
      if !target.damagestate.substitute
        if target.hasWorkingAbility(:CURSEDBODY,true) && @battle.pbRandom(10)<3
          if user.effects[PBEffects::Disable]<=0 && move.pp>0 && !user.isFainted?
            user.effects[PBEffects::Disable]=4
            user.effects[PBEffects::DisableMove]=move.id
            @battle.pbDisplay(_INTL("{1}'s {2} disabled {3}!",target.pbThis,
               PBAbilities.getName(target.ability),user.pbThis(true)))
            PBDebug.log("[#{target.pbThis}'s Cursed Body disabled #{user.pbThis(true)}]")
          end
        end
        # Illusion goes here
        if target.hasWorkingAbility(:JUSTIFIED) &&
           isConst?(movetype,PBTypes,:DARK)
          PBDebug.log("[#{target.pbThis}'s Justified triggered]")
          if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
               target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        # Magician goes here
        if target.hasWorkingAbility(:RATTLED) &&
           (isConst?(movetype,PBTypes,:BUG) ||
            isConst?(movetype,PBTypes,:DARK) ||
            isConst?(movetype,PBTypes,:GHOST))
          PBDebug.log("[#{target.pbThis}'s Rattled triggered]")
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",
               target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
        if target.hasWorkingAbility(:WEAKARMOR) && move.pbIsPhysical?(movetype)
          PBDebug.log("[#{target.pbThis}'s Weak Armor triggered]")
          if target.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
            target.pbReduceStatBasic(PBStats::DEFENSE,1)
            @battle.pbCommonAnimation("StatDown",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} lowered its Defense!",
               target.pbThis,PBAbilities.getName(target.ability)))
          end
          if target.pbCanIncreaseStatStage?(PBStats::SPEED)
            target.pbIncreaseStatBasic(PBStats::SPEED,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",
               target.pbThis,PBAbilities.getName(target.ability)))
          end
        end
      end
      if target.hasWorkingItem(:AIRBALLOON,true)
        target.pokemon.itemRecycle=target.item
        target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
        target.item=0
        @battle.pbDisplay(_INTL("{1}'s Air Balloon popped!",target.pbThis))
        PBDebug.log("[#{target.pbThis}'s Air Balloon was popped]")
      end
      if target.hasWorkingItem(:ABSORBBULB) && isConst?(movetype,PBTypes,:WATER)
        PBDebug.log("[#{target.pbThis}'s Absorb Bulb triggered]")
        if target.pbCanIncreaseStatStage?(PBStats::SPATK)
          target.pbIncreaseStatBasic(PBStats::SPATK,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
             target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      if target.hasWorkingItem(:CELLBATTERY) && isConst?(movetype,PBTypes,:ELECTRIC)
        PBDebug.log("[#{target.pbThis}'s Cell Battery triggered]")
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
          target.pbIncreaseStatBasic(PBStats::ATTACK,1)
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
             target.pbThis,PBItems.getName(target.item)))
          target.pokemon.itemRecycle=target.item
          target.pokemon.itemInitial=0 if target.pokemon.itemInitial==target.item
          target.item=0
        end
      end
      if target.hasWorkingAbility(:ANGERPOINT)
        PBDebug.log("[#{target.pbThis}'s Anger Point triggered]")
        if target.pbCanIncreaseStatStage?(PBStats::ATTACK) &&
            target.damagestate.critical
          target.stages[PBStats::ATTACK]=6
          @battle.pbCommonAnimation("StatUp",target,nil)
          @battle.pbDisplay(_INTL("{1}'s {2} maxed its Attack!",
             target.pbThis,PBAbilities.getName(target.ability)))
        end
      end
      # Record that Red Card/Eject Button triggered
      # Knock Off's effect(?)
    end
    user.pbAbilityCureCheck
    target.pbAbilityCureCheck
    # Synchronize here
    s=@battle.synchronize[0]
    t=@battle.synchronize[1]
#   PBDebug.log("[synchronize: #{@battle.synchronize.inspect}]")
    if s>=0 && t>=0 && @battle.battlers[s].hasWorkingAbility(:SYNCHRONIZE) &&
       @battle.synchronize[2]>0 && !@battle.battlers[t].isFainted?
# see [2024281]&0xF0, [202420C]
      sbattler=@battle.battlers[s]
      tbattler=@battle.battlers[t]
      if @battle.synchronize[2]==PBStatuses::POISON &&
         tbattler.pbCanPoisonSynchronize?(sbattler)
        tbattler.pbPoison(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} poisoned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::BURN &&
         tbattler.pbCanBurnSynchronize?(sbattler)
        tbattler.pbBurn(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} burned {3}!",sbattler.pbThis,
           PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      elsif @battle.synchronize[2]==PBStatuses::PARALYSIS &&
         tbattler.pbCanParalyzeSynchronize?(sbattler)
        tbattler.pbParalyze(sbattler)
        @battle.pbDisplay(_INTL("{1}'s {2} paralyzed {3}!  It may be unable to move!",
           sbattler.pbThis,PBAbilities.getName(sbattler.ability),tbattler.pbThis(true)))
      end
    end
  end

  def pbAbilityCureCheck
    return if self.isFainted?
    case self.status
    when PBStatuses::SLEEP
      if self.hasWorkingAbility(:VITALSPIRIT) || self.hasWorkingAbility(:INSOMNIA)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,PBAbilities.getName(@ability)))
        self.status=0
        PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its sleep]")
      end
    when PBStatuses::POISON
      if self.hasWorkingAbility(:IMMUNITY)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,PBAbilities.getName(@ability)))
        self.status=0
        PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its poison]")
      end
    when PBStatuses::BURN
      if self.hasWorkingAbility(:WATERVEIL)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,PBAbilities.getName(@ability)))
        self.status=0
        PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its burn]")
      end
    when PBStatuses::PARALYSIS
      if self.hasWorkingAbility(:LIMBER)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,PBAbilities.getName(@ability)))
        self.status=0
        PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its paralysis]")
      end
    when PBStatuses::FROZEN
      if self.hasWorkingAbility(:MAGMAARMOR)
        @battle.pbDisplay(_INTL("{1}'s {2} cured its ice problem!",pbThis,PBAbilities.getName(@ability)))
        self.status=0
        PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its frozen]")
      end
    end
    if self.hasWorkingAbility(:OWNTEMPO) && @effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,PBAbilities.getName(@ability)))
      @effects[PBEffects::Confusion]=0
      PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its confusion]")
    end
    if self.hasWorkingAbility(:OBLIVIOUS) && @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1}'s {2} cured its love problem!",pbThis,PBAbilities.getName(@ability)))
      @effects[PBEffects::Attract]=-1
      PBDebug.log("[#{pbThis}'s #{PBAbilities.getName(@ability)} cured its infatuation]")
    end
  end

################################################################################
# Held item effects
################################################################################
  def pbConfusionBerry(symbol,flavor,message1,message2)
    if isConst?(self.item,PBItems,symbol) && self.hp<=(self.totalhp/2).floor
      PBDebug.log("[#{pbThis} consumed its #{PBItems.getName(getID(PBItems,symbol))}]")
      pbRecoverHP((self.totalhp/8).floor,true)
      @battle.pbDisplay(message1)
      if (self.nature%5) == flavor && (self.nature/5).floor != (self.nature%5)
        @battle.pbDisplay(message2)
        if @effects[PBEffects::Confusion]==0 && !self.hasWorkingAbility(:OWNTEMPO)
          @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",self,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
          PBDebug.log("[#{pbThis} was confused by its berry]")
        end
      end
      @pokemon.itemRecycle=self.item
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end
  end

  def pbStatIncreasingBerry(symbol,stat,message)
    if isConst?(self.item,PBItems,symbol) && !self.pbTooHigh?(stat)
      if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
         self.hp<=(self.totalhp/4).floor
        PBDebug.log("[#{pbThis} consumed its #{PBItems.getName(getID(PBItems,symbol))}]")
        pbIncreaseStatBasic(stat,1)
        @battle.pbDisplay(message)
        @pokemon.itemRecycle=self.item
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
    end
  end

  def pbBerryCureCheck(hpcure=false)
    return if self.isFainted?
    unnerver=(pbOpposing1.hasWorkingAbility(:UNNERVE) ||
              pbOpposing2.hasWorkingAbility(:UNNERVE))
    itemname=(self.item==0) ? "" : PBItems.getName(self.item)
    if hpcure && self.hasWorkingItem(:BERRYJUICE) && self.hp<=(self.totalhp/2).floor
      PBDebug.log("[#{pbThis} consumed its #{itemname}]")
      self.pbRecoverHP(20,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
      @pokemon.itemRecycle=self.item
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end
    if !unnerver
      if hpcure
        if self.hasWorkingItem(:ORANBERRY) && self.hp<=(self.totalhp/2).floor
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.pbRecoverHP(10,true)
          @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
        if self.hasWorkingItem(:SITRUSBERRY) && self.hp<=(self.totalhp/2).floor
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.pbRecoverHP((self.totalhp/4).floor,true)
          @battle.pbDisplay(_INTL("{1}'s {2} restored health!",pbThis,itemname))   
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      end
      case self.status
      when PBStatuses::SLEEP
        if self.hasWorkingItem(:CHESTOBERRY)
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.status=0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      when PBStatuses::POISON
        if self.hasWorkingItem(:PECHABERRY)
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.status=0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      when PBStatuses::BURN
        if self.hasWorkingItem(:RAWSTBERRY)
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.status=0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      when PBStatuses::PARALYSIS
        if self.hasWorkingItem(:CHERIBERRY)
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.status=0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      when PBStatuses::FROZEN
        if self.hasWorkingItem(:ASPEARBERRY)
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          self.status=0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its ice problem!",pbThis,itemname))
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      end
      if hpcure && self.hasWorkingItem(:LEPPABERRY)
        for i in 0...@pokemon.moves.length
          pokemove=@pokemon.moves[i]
          battlermove=self.moves[i]
          if pokemove.pp==0 && pokemove.id!=0
            movename=PBMoves.getName(pokemove.id)
            pokemove.pp=10
            pokemove.pp=pokemove.totalpp if pokemove.pp>pokemove.totalpp 
            battlermove.pp=pokemove.pp
            @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s PP!",pbThis,itemname,movename)) 
            @pokemon.itemRecycle=self.item
            @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
            self.item=0
            break
          end
        end
      end
      if self.hasWorkingItem(:PERSIMBERRY) && @effects[PBEffects::Confusion]>0
        PBDebug.log("[#{pbThis} consumed its #{itemname}]")
        @effects[PBEffects::Confusion]=0
        @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if self.hasWorkingItem(:LUMBERRY) &&
         (self.status>0 || @effects[PBEffects::Confusion]>0)
        PBDebug.log("[#{pbThis} consumed its #{itemname}]")
        st=self.status; conf=@effects[PBEffects::Confusion]
        self.status=0
        @effects[PBEffects::Confusion]=0
        if conf>0
          @battle.pbDisplay(_INTL("{1}'s {2} cured its confusion problem!",pbThis,itemname))
        else
          case st
          when PBStatuses::SLEEP
            @battle.pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",pbThis,itemname))
          when PBStatuses::POISON
            @battle.pbDisplay(_INTL("{1}'s {2} cured its poison problem!",pbThis,itemname))
          when PBStatuses::BURN
            @battle.pbDisplay(_INTL("{1}'s {2} cured its burn problem!",pbThis,itemname))
          when PBStatuses::PARALYSIS
            @battle.pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",pbThis,itemname))
          when PBStatuses::FROZEN
            @battle.pbDisplay(_INTL("{1}'s {2} cured its frozen problem!",pbThis,itemname))
          end
        end
        @pokemon.itemRecycle=self.item
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
      if hpcure
        pbConfusionBerry(:FIGYBERRY,0,
           _INTL("{1}'s {2} restored health!",pbThis,itemname),
           _INTL("For {1}, the {2} was too spicy!",pbThis(true),itemname))
        pbConfusionBerry(:WIKIBERRY,3,
           _INTL("{1}'s {2} restored health!",pbThis,itemname),
           _INTL("For {1}, the {2} was too dry!",pbThis(true),itemname))
        pbConfusionBerry(:MAGOBERRY,2,
           _INTL("{1}'s {2} restored health!",pbThis,itemname),
           _INTL("For {1}, the {2} was too sweet!",pbThis(true),itemname))
        pbConfusionBerry(:AGUAVBERRY,4,
           _INTL("{1}'s {2} restored health!",pbThis,itemname),
           _INTL("For {1}, the {2} was too bitter!",pbThis(true),itemname))
        pbConfusionBerry(:IAPAPABERRY,1,
           _INTL("{1}'s {2} restored health!",pbThis,itemname),
           _INTL("For {1}, the {2} was too sour!",pbThis(true),itemname))
        pbStatIncreasingBerry(:LIECHIBERRY,PBStats::ATTACK,
           _INTL("Using its {1}, the Attack of {2} rose!",itemname,pbThis(true)))
        pbStatIncreasingBerry(:GANLONBERRY,PBStats::DEFENSE,
           _INTL("Using its {1}, the Defense of {2} rose!",itemname,pbThis(true)))
        pbStatIncreasingBerry(:SALACBERRY,PBStats::SPEED,
           _INTL("Using its {1}, the Speed of {2} rose!",itemname,pbThis(true)))
        pbStatIncreasingBerry(:PETAYABERRY,PBStats::SPATK,
           _INTL("Using its {1}, the Special Attack of {2} rose!",itemname,pbThis(true)))
        pbStatIncreasingBerry(:APICOTBERRY,PBStats::SPDEF,
           _INTL("Using its {1}, the Special Defense of {2} rose!",itemname,pbThis(true)))
      end
      if hpcure && self.hasWorkingItem(:LANSATBERRY) && @effects[PBEffects::FocusEnergy]==0
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
           self.hp<=(self.totalhp/4).floor
          PBDebug.log("[#{pbThis} consumed its #{itemname}]")
          @battle.pbDisplay(_INTL("{1} used its {2} to get pumped!",pbThis,itemname))
          @effects[PBEffects::FocusEnergy]=1
          @pokemon.itemRecycle=self.item
          @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
          self.item=0
        end
      end
      if hpcure && self.hasWorkingItem(:STARFBERRY)
        if (self.hasWorkingAbility(:GLUTTONY) && self.hp<=(self.totalhp/2).floor) ||
           self.hp<=(self.totalhp/4).floor
          stats=[]
          messages=[]
          messages[PBStats::ATTACK]=_INTL("Using {1}, the Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::DEFENSE]=_INTL("Using {1}, the Defense of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPEED]=_INTL("Using {1}, the Speed of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPATK]=_INTL("Using {1}, the Special Attack of {2} rose sharply!",itemname,pbThis(true))
          messages[PBStats::SPDEF]=_INTL("Using {1}, the Special Defense of {2} rose sharply!",itemname,pbThis(true))
          for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF]
            stats[stats.length]=i if !pbTooHigh?(i)
          end
          if stats.length>0
            PBDebug.log("[#{pbThis} consumed its #{itemname}]")
            stat=stats[@battle.pbRandom(stats.length)]
            pbIncreaseStatBasic(stat,2)
            @battle.pbDisplay(messages[stat])
            @pokemon.itemRecycle=self.item
            @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
            self.item=0
          end
        end
      end
    end
    if self.hasWorkingItem(:WHITEHERB)
      reducedstats=false
      for i in [PBStats::ATTACK,PBStats::DEFENSE,
                PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                PBStats::EVASION,PBStats::ACCURACY]
        if @stages[i]<0
          @stages[i]=0; reducedstats=true
        end
      end
      if reducedstats
        PBDebug.log("[#{pbThis} consumed its #{itemname}]")
        @battle.pbDisplay(_INTL("{1}'s {2} restored its status!",pbThis,itemname))
        @pokemon.itemRecycle=self.item
        @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
        self.item=0
      end
    end
    if self.hasWorkingItem(:MENTALHERB) &&
       (@effects[PBEffects::Attract]>=0 ||
       @effects[PBEffects::Taunt]>0 ||
       @effects[PBEffects::Encore]>0 ||
       @effects[PBEffects::Torment] ||
       @effects[PBEffects::Disable]>0 ||
       @effects[PBEffects::HealBlock]>0)
      PBDebug.log("[#{pbThis} consumed its #{itemname}]")
      @battle.pbDisplay(_INTL("{1}'s {2} cured its love problem!",pbThis,itemname)) if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("{1} is taunted no more!",pbThis)) if @effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("{1}'s encore ended!",pbThis)) if @effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("{1} is tormented no more!",pbThis)) if @effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("{1} is disabled no more!",pbThis)) if @effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("{1}'s heal block ended!",pbThis)) if @effects[PBEffects::HealBlock]>0
      @effects[PBEffects::Attract]=-1
      @effects[PBEffects::Taunt]=0
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreMove]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::Torment]=false
      @effects[PBEffects::Disable]=0
      @effects[PBEffects::HealBlock]=0
      @pokemon.itemRecycle=self.item
      @pokemon.itemInitial=0 if @pokemon.itemInitial==self.item
      self.item=0
    end
    if hpcure && self.hasWorkingItem(:LEFTOVERS) && self.hp!=self.totalhp &&
       @effects[PBEffects::HealBlock]==0
      PBDebug.log("[#{pbThis}'s Leftovers triggered]")
      pbRecoverHP((self.totalhp/16).floor,true)
      @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",pbThis,itemname))
    end
    if hpcure && self.hasWorkingItem(:BLACKSLUDGE)
      if pbHasType?(:POISON)
        if self.hp!=self.totalhp
          PBDebug.log("[#{pbThis}'s Black Sludge triggered]")
          pbRecoverHP((self.totalhp/16).floor,true)
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP a little!",pbThis,itemname))
        end
      elsif !self.hasWorkingAbility(:MAGICGUARD)
        PBDebug.log("[#{pbThis}'s Black Sludge triggered]")
        pbReduceHP((self.totalhp/8).floor,true)
        @battle.pbDisplay(_INTL("{1} was hurt by its {2}!",pbThis,itemname))
      end
      pbFaint if self.isFainted?
    end
  end

################################################################################
# Move user and targets
################################################################################
  def pbFindUser(choice,targets)
    move=choice[2]
    target=choice[3]
    user=self   # Normally, the user is self
    # Targets in normal cases
    case pbTarget(move)
    when PBTargets::SingleNonUser
      if target>=0
        targetBattler=@battle.battlers[target]
        if !pbIsOpposing?(targetBattler.index)
          if !pbAddTarget(targets,targetBattler)
            pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
          end
        else
          pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::SingleOpposing
      if target>=0
        targetBattler=@battle.battlers[target]
        if !pbIsOpposing?(targetBattler.index)
          if !pbAddTarget(targets,targetBattler)
            pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
          end
        else
          pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
        end
      else
        pbRandomTarget(targets)
      end
    when PBTargets::OppositeOpposing
      pbAddTarget(targets,pbOppositeOpposing) if !pbAddTarget(targets,pbOppositeOpposing2)
    when PBTargets::RandomOpposing
      pbRandomTarget(targets)
    when PBTargets::AllOpposing
      # Just pbOpposing1 because partner is determined late
      pbAddTarget(targets,pbOpposing2) if !pbAddTarget(targets,pbOpposing1)
    when PBTargets::AllNonUsers
      for i in 0...4 # not ordered by priority
        pbAddTarget(targets,@battle.battlers[i]) if i!=@index
      end
    when PBTargets::UserOrPartner
      if target>=0 # Pre-chosen target
        targetBattler=@battle.battlers[target]
        pbAddTarget(targets,targetBattler.pbPartner) if !pbAddTarget(targets,targetBattler)
      else
        pbAddTarget(targets,self)
      end
    when PBTargets::Partner
      pbAddTarget(targets,pbPartner)
    else
      move.pbAddTarget(targets,self)
    end
    return user
  end

  def pbChangeUser(thismove,user)
    priority=@battle.pbPriority
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          PBDebug.log("[#{user.pbThis}'s #{thismove.name} was Snatched by #{i.pbThis(true)}]")
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      end
    end
    return user
  end

  def pbTarget(move)
    target=move.target
    if move.function==0x10D && pbHasType?(:GHOST) # Curse
      target=PBTargets::OppositeOpposing
    end
    return target
  end

  def pbAddTarget(targets,target)
    if !target.isFainted?
      targets[targets.length]=target
      return true
    end
    return false
  end

  def pbRandomTarget(targets)
    choices=[]
    pbAddTarget(choices,pbOpposing1)
    pbAddTarget(choices,pbOpposing2)
    if choices.length>0
      pbAddTarget(targets,choices[@battle.pbRandom(choices.length)])
    end
  end

  def pbChangeTarget(thismove,userandtarget,targets)
    priority=@battle.pbPriority
    changeeffect=0
    user=userandtarget[0]
    target=userandtarget[1]
    # LightningRod here, considers Hidden Power as Normal
    if targets.length==1 && isConst?(thismove.type,PBTypes,:ELECTRIC) && 
       !target.hasWorkingAbility(:LIGHTNINGROD)
      for i in priority # use Pokémon earliest in priority
        next if !pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:LIGHTNINGROD)
          target=i # X's LightningRod took the attack!
          changeeffect=1
          break
        end
      end
    end
    # Storm Drain here, considers Hidden Power as Normal
    if targets.length==1 && isConst?(thismove.type,PBTypes,:WATER) && 
       !target.hasWorkingAbility(:STORMDRAIN)
      for i in priority # use Pokémon earliest in priority
        next if !pbIsOpposing?(i.index)
        if i.hasWorkingAbility(:STORMDRAIN)
          target=i # X's Storm Drain took the attack!
          changeeffect=2
          break
        end
      end
    end
    # Change target to user of Follow Me (overrides Magic Coat
    # because check for Magic Coat below uses this target)
    if thismove.target==PBTargets::SingleNonUser ||
       thismove.target==PBTargets::SingleOpposing ||
       thismove.target==PBTargets::RandomOpposing ||
       thismove.target==PBTargets::OppositeOpposing
      for i in priority # use Pokémon latest in priority
        next if !pbIsOpposing?(i.index)
        if i.effects[PBEffects::FollowMe]
          PBDebug.log("[#{i.pbThis}'s Follow Me triggered]")
          target=i # change target to this
        end
      end
    end
    # TODO: Pressure here is incorrect if Magic Coat redirects target
    if target.hasWorkingAbility(:PRESSURE)
      PBDebug.log("[#{target.pbThis}'s Pressure triggered (pbChangeTarget)]")
      pbReducePP(thismove) # Reduce PP
    end  
    # Change user to user of Snatch
    if thismove.canSnatch?
      for i in priority
        if i.effects[PBEffects::Snatch]
          @battle.pbDisplay(_INTL("{1} Snatched {2}'s move!",i.pbThis,user.pbThis(true)))
          i.effects[PBEffects::Snatch]=false
          target=user
          user=i
          PBDebug.log("[#{user.pbThis}'s #{thismove.name} was Snatched by #{i.pbThis(true)}]")
          # Snatch's PP is reduced if old user has Pressure
          userchoice=@battle.choices[user.index][1]
          if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
            PBDebug.log("[#{target.pbThis}'s Pressure triggered (part of Snatch)]")
            pressuremove=user.moves[userchoice]
            pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
          end
        end
      end
    end
    userandtarget[0]=user
    userandtarget[1]=target
    if target.hasWorkingAbility(:SOUNDPROOF) && thismove.isSoundBased? &&
       thismove.function!=0x19 &&   # Heal Bell handled elsewhere
       thismove.function!=0xE5      # Perish Song handled elsewhere
      PBDebug.log("[#{target.pbThis}'s Soundproof blocked #{user.pbThis(true)}'s #{thismove.name}]")
      @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",target.pbThis,
         PBAbilities.getName(target.ability),thismove.name))
      return false
    end
    if thismove.canMagicCoat? && target.effects[PBEffects::MagicCoat]
      # switch user and target
      PBDebug.log("[#{user.pbThis}'s #{thismove.name} was Magic Coated by #{target.pbThis(true)}]")
      changeeffect=3
      target.effects[PBEffects::MagicCoat]=false
      tmp=user
      user=target
      target=tmp
      # Magic Coat's PP is reduced if old user has Pressure
      userchoice=@battle.choices[user.index][1]
      if target.hasWorkingAbility(:PRESSURE) && userchoice>=0
        PBDebug.log("[#{target.pbThis}'s Pressure triggered (part of Magic Coat)]")
        pressuremove=user.moves[userchoice]
        pbSetPP(pressuremove,pressuremove.pp-1) if pressuremove.pp>0
      end
    end
    if thismove.canMagicCoat? && target.hasWorkingAbility(:MAGICBOUNCE)
      # switch user and target
      PBDebug.log("[#{user.pbThis}'s #{thismove.name} was Magic Bounced by #{target.pbThis(true)}]")
      changeeffect=4
      tmp=user
      user=target
      target=tmp
    end
    if changeeffect==1
      @battle.pbDisplay(_INTL("{1}'s LightningRod took the move!",target.pbThis))
      PBDebug.log("[#{target.pbThis}'s LightningRod drew the move in]")
    elsif changeeffect==2
      @battle.pbDisplay(_INTL("{1}'s Storm Drain took the move!",target.pbThis))
      PBDebug.log("[#{target.pbThis}'s Storm Drain drew the move in]")
    elsif changeeffect==3
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1}'s {2} was bounced back by Magic Coat!",user.pbThis,thismove.name))
    elsif changeeffect==4
      # Target refers to the move's old user
      @battle.pbDisplay(_INTL("{1} bounced the {2} back!",target.pbThis,thismove.name))
    end
    userandtarget[0]=user
    userandtarget[1]=target
    return true
  end

################################################################################
# Move PP
################################################################################
  def pbSetPP(move,pp)
    move.pp=pp
    #Not effects[PBEffects::Mimic], since Mimic can't copy Mimic
    if move.thismove && move.id==move.thismove.id && !@effects[PBEffects::Transform]
      move.thismove.pp=pp
    end
  end

  def pbReducePP(move)
    #TODO: Pressure
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::Bide]>0 || 
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Uproar]>0
      # No need to reduce PP if two-turn attack
      return true
    end
    return true if move.pp<0   # No need to reduce PP for special calls of moves
    return true if move.totalpp==0   # Infinite PP, can always be used
    return false if move.pp==0
    if move.pp>0
      pbSetPP(move,move.pp-1)
    end
    return true
  end

  def pbReducePPOther(move)
    pbSetPP(move,move.pp-1) if move.pp>0
  end

################################################################################
# Using a move
################################################################################
  def pbObedienceCheck?(choice)
    return true if choice[0]!=1
    if @battle.pbOwnedByPlayer?(@index) && @battle.internalbattle
      badgelevel=10
      badgelevel=20  if @battle.pbPlayer.numbadges>=1
      badgelevel=30  if @battle.pbPlayer.numbadges>=2
      badgelevel=40  if @battle.pbPlayer.numbadges>=3
      badgelevel=50  if @battle.pbPlayer.numbadges>=4
      badgelevel=60  if @battle.pbPlayer.numbadges>=5
      badgelevel=70  if @battle.pbPlayer.numbadges>=6
      badgelevel=80  if @battle.pbPlayer.numbadges>=7
      badgelevel=100 if @battle.pbPlayer.numbadges>=8
      move=choice[2]
      disobedient=false
      if @pokemon.isForeign?(@battle.pbPlayer) && @level>badgelevel
        a=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        disobedient|=a<badgelevel
      end
      if self.respond_to?("pbHyperModeObedience")
        disobedient|=!self.pbHyperModeObedience(move)
      end
      if disobedient
        PBDebug.log("[#{pbThis} disobeyed orders]")
        @effects[PBEffects::Rage]=false
        if self.status==PBStatuses::SLEEP && 
           (move.function==0x11 || move.function==0xB4) # Snore, Sleep Talk
          @battle.pbDisplay(_INTL("{1} ignored orders while asleep!",pbThis)) 
          return false
        end
        b=((@level+badgelevel)*@battle.pbRandom(256)/255).floor
        if b<badgelevel
          return false if !@battle.pbCanShowFightMenu?(@index)
          othermoves=[]
          for i in 0...4
            next if i==choice[1]
            othermoves[othermoves.length]=i if @battle.pbCanChooseMove?(@index,i,false)
          end
          if othermoves.length>0
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) 
            newchoice=othermoves[@battle.pbRandom(othermoves.length)]
            choice[1]=newchoice
            choice[2]=@moves[newchoice]
            choice[3]=-1
          end
          return true
        elsif self.status!=PBStatuses::SLEEP
          c=@level-b
          r=@battle.pbRandom(256)
          if r<c && pbCanSleep?(false,true)
            pbSleepSelf()
            @battle.pbDisplay(_INTL("{1} took a nap!",pbThis))
            return false
          end
          r-=c
          if r<c
            @battle.pbDisplay(_INTL("It hurt itself from its confusion!"))
            pbConfusionDamage
          else
            message=@battle.pbRandom(4)
            @battle.pbDisplay(_INTL("{1} ignored orders!",pbThis)) if message==0
            @battle.pbDisplay(_INTL("{1} turned away!",pbThis)) if message==1
            @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis)) if message==2
            @battle.pbDisplay(_INTL("{1} pretended not to notice!",pbThis)) if message==3
          end
          return false
        end
      end
      return true
    else
      return true
    end
  end

  def pbSuccessCheck(thismove,user,target,accuracy=true)
    if user.effects[PBEffects::TwoTurnAttack]>0
      PBDebug.log("[#{user.pbThis}: Using two-turn attack]")
      return true
    end
    # TODO: "Before Protect" applies to Counter/Mirror Coat
    if thismove.function==0xDE && target.status!=PBStatuses::SLEEP # Dream Eater
      @battle.pbDisplay(_INTL("{1} wasn't affected!",target.pbThis))
      PBDebug.log("[#{user.pbThis}: Dream Eater's target isn't asleep]")
      return false
    end
    if thismove.function==0x113 && user.effects[PBEffects::Stockpile]==0 # Spit Up
      @battle.pbDisplay(_INTL("But it failed to spit up a thing!"))
      PBDebug.log("[#{user.pbThis}: Spit Up did nothing as Stockpile's count is 0]")
      return false
    end
    if target.effects[PBEffects::Protect] && thismove.canProtectAgainst? &&
       !target.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",target.pbThis))
      @battle.successStates[user.index].protected=true
      PBDebug.log("[#{user.pbThis}: Protect stopped the attack]")
      return false
    end
    # TODO: Mind Reader/Lock-On
    # --Sketch/FutureSight/PsychUp work even on Fly/Bounce/Dive/Dig
    if thismove.pbMoveFailed(user,target) # TODO: Applies to Snore/Fake Out
      @battle.pbDisplay(_INTL("But it failed!"))
      PBDebug.log(sprintf("[%s: pbMoveFailed for function code %02X]",user.pbThis,thismove.function))
      return false
    end
    if thismove.basedamage>0 && thismove.function!=0x02 && # Struggle
       thismove.function!=0x111 # Future Sight
      type=thismove.pbType(thismove.type,user,target)
      typemod=thismove.pbTypeModifier(type,user,target)
      # Airborne-based immunity to Ground moves
      if isConst?(type,PBTypes,:GROUND) && target.isAirborne? &&
         !target.hasWorkingItem(:RINGTARGET)
        if target.hasWorkingAbility(:LEVITATE)
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Levitate!",target.pbThis))
          PBDebug.log("[#{user.pbThis}: Ground-type move missed because of Levitate]")
          return false
        end
        if target.hasWorkingItem(:AIRBALLOON)
          @battle.pbDisplay(_INTL("{1}'s Air Balloon makes Ground moves miss!",target.pbThis))
          PBDebug.log("[#{user.pbThis}: move missed because of Air Balloon]")
          return false
        end
        if target.effects[PBEffects::MagnetRise]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Magnet Rise!",target.pbThis))
          PBDebug.log("[#{user.pbThis}: Ground-type move missed because of Magnet Rise]")
          return false
        end
        if target.effects[PBEffects::Telekinesis]>0
          @battle.pbDisplay(_INTL("{1} makes Ground moves miss with Telekinesis!",target.pbThis))
          PBDebug.log("[#{user.pbThis}: Ground-type move missed because of Telekinesis]")
          return false
        end
      end
      if target.hasWorkingAbility(:WONDERGUARD) && typemod<=4 && type>=0
        @battle.pbDisplay(_INTL("{1} avoided damage with Wonder Guard!",target.pbThis))
        PBDebug.log("[#{user.pbThis}: move thwarted by Wonder Guard]")
        return false 
      end
      if typemod==0
        @battle.pbDisplay(_INTL("It doesn't affect\r\n{1}...",target.pbThis(true)))
        PBDebug.log("[#{user.pbThis}: target is immune to move's type]")
        return false 
      end
    end
    if accuracy
      if target.effects[PBEffects::LockOn]>0 && target.effects[PBEffects::LockOnPos]==user.index
        PBDebug.log("[#{user.pbThis}: Lock-On applies]")
        return true
      end
      miss=false
      invulmove=PBMoveData.new(target.effects[PBEffects::TwoTurnAttack]).function
      case invulmove
      when 0xC9, 0xCC # Fly, Bounce
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C || # Smack Down
                         isConst?(thismove.id,PBMoves,:WHIRLWIND)
      when 0xCA # Dig
        miss=true unless thismove.function==0x76 || # Earthquake
                         thismove.function==0x95    # Magnitude
      when 0xCB # Dive
        miss=true unless thismove.function==0x75 || # Surf
                         thismove.function==0xD0    # Whirlpool
      when 0xCD # Shadow Force
        miss=true
      when 0xCE # Sky Drop
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      end
      if target.effects[PBEffects::SkyDrop]
        miss=true unless thismove.function==0x08 ||  # Thunder
                         thismove.function==0x15 ||  # Hurricane
                         thismove.function==0x77 ||  # Gust
                         thismove.function==0x78 ||  # Twister
                         thismove.function==0x11B || # Sky Uppercut
                         thismove.function==0x11C    # Smack Down
      end
      if miss || !thismove.pbAccuracyCheck(user,target) # Includes Counter/Mirror Coat
        PBDebug.log("[#{user.pbThis}: failed accuracy check or target is semi-invulnerable]")
        if thismove.target==PBTargets::AllOpposing && 
           (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) > 1
          # All opposing Pokémon
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.target==PBTargets::AllNonUsers && 
           (!user.pbOpposing1.isFainted? ? 1 : 0) + (!user.pbOpposing2.isFainted? ? 1 : 0) + (!user.pbPartner.isFainted? ? 1 : 0) > 1
          # All non-users
          @battle.pbDisplay(_INTL("{1} avoided the attack!",target.pbThis))
        elsif thismove.function==0xDC # Leech Seed
          @battle.pbDisplay(_INTL("{1} evaded the attack!",target.pbThis))
        else
          @battle.pbDisplay(_INTL("{1}'s attack missed!",user.pbThis))
        end
        return false
      end
    end
    return true
  end

  def pbTryUseMove(choice,thismove,turneffects)
    return true if turneffects[PBEffects::PassedTrying]
    # TODO: Return true if attack has been Mirror Coated once already
    return false if !pbObedienceCheck?(choice)
    # TODO: If being Sky Dropped, return false
    # TODO: Gravity prevents airborne-based moves here
    if @effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      @battle.pbDisplay(_INTL("{1} can't use {2} after the taunt!",
         pbThis,thismove.name))
      PBDebug.log("[#{pbThis} can't use #{thismove.name} after the taunt]")
      return false
    end
    if @effects[PBEffects::HealBlock]>0 && thismove.isHealingMove?
      @battle.pbDisplay(_INTL("{1} can't use {2} after the Heal Block!",
         pbThis,thismove.name))
      PBDebug.log("[#{pbThis} can't use #{thismove.name} after the Heal Block]")
      return false
    end
    if @effects[PBEffects::Torment] && thismove.id==@lastMoveUsed &&
       thismove.id!=@battle.struggle.id
      pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",
         pbThis))
      PBDebug.log("[#{pbThis} can't use #{thismove.name} due to the torment]")
      return false
    end
    if pbOpposing1.effects[PBEffects::Imprison]
      if thismove.id==pbOpposing1.moves[0].id ||
         thismove.id==pbOpposing1.moves[1].id ||
         thismove.id==pbOpposing1.moves[2].id ||
         thismove.id==pbOpposing1.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
           pbThis,thismove.name))
        PBDebug.log("[#{thismove.name} was imprisoned; #{pbOpposing1.pbThis} has: #{pbOpposing1.moves[0].id}, #{pbOpposing1.moves[1].id},#{pbOpposing1.moves[2].id} #{pbOpposing1.moves[3].id}]")
        return false
      end
    end
    if pbOpposing2.effects[PBEffects::Imprison]
      if thismove.id==pbOpposing2.moves[0].id ||
         thismove.id==pbOpposing2.moves[1].id ||
         thismove.id==pbOpposing2.moves[2].id ||
         thismove.id==pbOpposing2.moves[3].id
        @battle.pbDisplay(_INTL("{1} can't use the sealed {2}!",
           pbThis,thismove.name))
        PBDebug.log("[#{thismove.name} was imprisoned; #{pbOpposing2.pbThis} has: #{pbOpposing2.moves[0].id}, #{pbOpposing2.moves[1].id},#{pbOpposing2.moves[2].id} #{pbOpposing2.moves[3].id}]")
        return false
      end
    end
    if @effects[PBEffects::Disable]>0 && thismove.id==@effects[PBEffects::DisableMove]
      @battle.pbDisplayPaused(_INTL("{1}'s {2} is disabled!",pbThis,thismove.name))
      PBDebug.log("[#{pbThis}'s #{thismove.name} is disabled so it couldn't move]")
      return false
    end
    if self.hasWorkingAbility(:TRUANT) && @effects[PBEffects::Truant]
      @battle.pbDisplay(_INTL("{1} is loafing around!",pbThis))
      PBDebug.log("[#{pbThis} is loafing around due to Truant]")
      return false
    end
    if choice[1]==-2 # Battle Palace
      @battle.pbDisplay(_INTL("{1} appears incapable of using its power!",pbThis))
      PBDebug.log("[Battle Palace: #{pbThis} is incapable of using its power]")
      return false
    end
    if @effects[PBEffects::HyperBeam]>0
      @battle.pbDisplay(_INTL("{1} must recharge!",pbThis))
      PBDebug.log("[#{pbThis} must recharge after using #{PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove)).name}]")
      return false
    end
    if self.status==PBStatuses::SLEEP
      self.statusCount-=1
      self.statusCount-=1 if self.hasWorkingAbility(:EARLYBIRD)
      if self.statusCount<=0
        self.pbCureStatus
        PBDebug.log("[#{pbThis} woke up]")
      else
        self.pbContinueStatus
        PBDebug.log("[#{pbThis} remained asleep (count: #{self.statusCount})]")
        if !thismove.pbCanUseWhileAsleep? # Snore/Sleep Talk
          PBDebug.log("[#{pbThis} couldn't use #{thismove.name} while asleep]")
          return false
        end
      end
    end
    if self.status==PBStatuses::FROZEN
      if thismove.canThawUser?
        self.pbCureStatus(false)
        @battle.pbDisplay(_INTL("{1} was defrosted by {2}!",pbThis,thismove.name))
        pbCheckForm
        PBDebug.log("[#{pbThis} was defrosted by #{thismove.name}]")
      elsif @battle.pbRandom(10)<2
        self.pbCureStatus
        pbCheckForm
        PBDebug.log("[#{pbThis} defrosted]")
      elsif !thismove.canThawUser?
        self.pbContinueStatus
        PBDebug.log("[#{pbThis} remained frozen and couldn't move]")
        return false
      end
    end
    if @effects[PBEffects::Confusion]>0
      @effects[PBEffects::Confusion]-=1
      if @effects[PBEffects::Confusion]<=0
        pbCureConfusion
      else
        pbContinueConfusion
        PBDebug.log("[#{pbThis} remained confused (count: #{@effects[PBEffects::Confusion]})]")
        if @battle.pbRandom(2)==0
          @battle.pbDisplay(_INTL("It hurt itself from its confusion!")) 
          PBDebug.log("[#{pbThis} hurt itself in its confusion and couldn't move]")
          pbConfusionDamage
          return false
        end
      end
    end
    if @effects[PBEffects::Flinch]
      @effects[PBEffects::Flinch]=false
      if self.hasWorkingAbility(:INNERFOCUS)
        @battle.pbDisplay(_INTL("{1} won't flinch because of its {2}!",
           self.pbThis,PBAbilities.getName(self.ability)))
        PBDebug.log("[#{pbThis} didn't flinch because of Inner Focus]")
      else
        @battle.pbDisplay(_INTL("{1} flinched and couldn't move!",self.pbThis))
        PBDebug.log("[#{pbThis} flinched and couldn't move]")
        if self.hasWorkingAbility(:STEADFAST)
          PBDebug.log("[#{pbThis}'s Steadfast triggered]")
          if pbCanIncreaseStatStage?(PBStats::SPEED)
            pbIncreaseStat(PBStats::SPEED,1,false)
            @battle.pbDisplay(_INTL("{1}'s {2} raised its speed!",
               self.pbThis,PBAbilities.getName(self.ability)))
          end
        end
        return false
      end
    end
    if @effects[PBEffects::Attract]>=0
      pbAnnounceAttract(@battle.battlers[@effects[PBEffects::Attract]])
      if @battle.pbRandom(2)==0
        pbContinueAttract
        PBDebug.log("[#{pbThis} was infatuated and couldn't move]")
        return false
      end
    end
    if self.status==PBStatuses::PARALYSIS
      if @battle.pbRandom(4)==0
        pbContinueStatus
        PBDebug.log("[#{pbThis} was fully paralysed and couldn't move]")
        return false
      end
    end
    turneffects[PBEffects::PassedTrying]=true
    return true
  end

  def pbConfusionDamage
    self.damagestate.reset
    confmove=PokeBattle_Confusion.new(@battle,nil)
    confmove.pbEffect(self,self)
    pbFaint if self.isFainted?
  end

  def pbUpdateTargetedMove(thismove,user)
    # TODO: Snatch, moves that use other moves
    # TODO: All targeting cases
    # Two-turn attacks, Magic Coat, Future Sight, Counter/MirrorCoat/Bide handled
  end

  def pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,nocheck=false,alltargets=nil,showanimation=true)
    realnumhits=0
    totaldamage=0
    destinybond=false
    for i in 0...numhits
      # Check success (accuracy/evasion calculation)
      if !nocheck &&
         !pbSuccessCheck(thismove,user,target,i==0 || thismove.function==0xBF) # Triple Kick
        if thismove.function==0xBF && realnumhits>0   # Triple Kick
          break   # Considered a success if Triple Kick hits at least once
        elsif thismove.function==0x10B   # Hi Jump Kick, Jump Kick
          #TODO: Not shown if message is "It doesn't affect XXX..."
          PBDebug.log("[#{user.pbThis} took crash damage]")
          @battle.pbDisplay(_INTL("{1} kept going and crashed!",user.pbThis))
          damage=[1,(user.totalhp/2).floor].max
          if damage>0
            @battle.scene.pbDamageAnimation(user,0)
            user.pbReduceHP(damage)
          end
          user.pbFaint if user.isFainted?
        end
        user.effects[PBEffects::Outrage]=0 if thismove.function==0xD2 # Outrage
        user.effects[PBEffects::Rollout]=0 if thismove.function==0xD3 # Rollout
        user.effects[PBEffects::FuryCutter]=0 if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::EchoedVoice]=0 if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::Stockpile]=0 if thismove.function==0x113 # Spit Up
        return
      end
      # Add to counters for moves which increase them when used in succession
      if thismove.function==0x91 # Fury Cutter
        user.effects[PBEffects::FuryCutter]+=1 if user.effects[PBEffects::FuryCutter]<4
      else
        user.effects[PBEffects::FuryCutter]=0
      end
      if thismove.function==0x92 # Echoed Voice
        user.effects[PBEffects::EchoedVoice]+=1 if user.effects[PBEffects::EchoedVoice]<5
      else
        user.effects[PBEffects::EchoedVoice]=0
      end
      # This hit will happen; count it
      realnumhits+=1
      # Damage calculation and/or main effect
      damage=thismove.pbEffect(user,target,i,alltargets,showanimation) # Recoil/drain, etc. are applied here
      totaldamage+=damage if damage>0
      if user.isFainted?
        user.pbFaint # no return
      end
      return if numhits>1 && target.damagestate.calcdamage<=0
      @battle.pbJudgeCheckpoint(user,thismove)
      # Additional effect
      if target.damagestate.calcdamage>0 &&
         !target.hasWorkingAbility(:SHIELDDUST) &&
         !user.hasWorkingAbility(:SHEERFORCE)
        addleffect=thismove.addlEffect
        addleffect*=2 if user.hasWorkingAbility(:SERENEGRACE)
        addleffect=100 if $DEBUG && Input.press?(Input::CTRL)
        if @battle.pbRandom(100)<addleffect
          PBDebug.log("[#{thismove.name}'s added effect triggered]")
          thismove.pbAdditionalEffect(user,target)
        end
      end
      # Ability effects
      pbEffectsOnDealingDamage(thismove,user,target,damage)
      # Grudge
      if !user.isFainted? && target.isFainted?
        if target.effects[PBEffects::Grudge] && target.pbIsOpposing?(user.index)
          thismove.pp=0
          @battle.pbDisplay(_INTL("{1}'s {2} lost all its PP due to the grudge!",
             user.pbThis,thismove.name))
          PBDebug.log("[#{thismove.name} lost all its PP due to #{target.pbThis(true)}'s grudge]")
        end
      end
      if target.isFainted?
        destinybond=destinybond || target.effects[PBEffects::DestinyBond]
        target.pbFaint # no return
      end
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted?
      break if target.isFainted?
      # Moxie goes here
      # Make the target flinch
      if target.damagestate.calcdamage>0 && !target.damagestate.substitute
        if !target.hasWorkingAbility(:SHIELDDUST)
          if (user.hasWorkingItem(:KINGSROCK) || user.hasWorkingItem(:RAZORFANG)) &&
             thismove.canKingsRock?
            if @battle.pbRandom(10)==0
              target.effects[PBEffects::Flinch]=true
              PBDebug.log("[King's Rock or Razor Fang triggered]")
            end
          elsif user.hasWorkingAbility(:STENCH) &&
                thismove.function!=0x09 && # Thunder Fang
                thismove.function!=0x0B && # Fire Fang
                thismove.function!=0x0E && # Ice Fang
                thismove.function!=0x0F && # flinch-inducing moves
                thismove.function!=0x10 && # Stomp
                thismove.function!=0x11 && # Snore
                thismove.function!=0x12 && # Fake Out
                thismove.function!=0x78 && # Twister
                thismove.function!=0xC7    # Sky Attack
            if @battle.pbRandom(10)==0
              target.effects[PBEffects::Flinch]=true
              PBDebug.log("[#{user.pbThis}'s Stench triggered]")
            end
          end
        end
      end
      if target.damagestate.calcdamage>0 && !target.isFainted?
        # Defrost
        if isConst?(thismove.pbType(thismove.type,user,target),PBTypes,:FIRE) &&
           target.status==PBStatuses::FROZEN
          target.pbCureStatus
        end
        # Rage
        if target.effects[PBEffects::Rage] && target.pbIsOpposing?(user.index)
          # TODO: Apparently triggers if opposing Pokémon uses Future Sight after a Future Sight attack
          PBDebug.log("[#{target.pbThis}'s Rage was triggered]")
          if target.pbCanIncreaseStatStage?(PBStats::ATTACK)
            target.pbIncreaseStatBasic(PBStats::ATTACK,1)
            @battle.pbCommonAnimation("StatUp",target,nil)
            @battle.pbDisplay(_INTL("{1}'s rage is building!",target.pbThis))
          end
        end
      end
      target.pbFaint if target.isFainted? # no return
      user.pbFaint if user.isFainted? # no return
      break if user.isFainted? || target.isFainted?
      # Berry check (maybe just called by ability effect, since only necessary Berries are checked)
      for j in 0...4
        @battle.battlers[j].pbBerryCureCheck
      end
      break if user.isFainted? || target.isFainted?
      target.pbUpdateTargetedMove(thismove,user)
      break if target.damagestate.calcdamage<=0
    end
    turneffects[PBEffects::TotalDamage]+=totaldamage if totaldamage>0
    # Battle Arena only - attack is successful
    @battle.successStates[user.index].useState=2
    @battle.successStates[user.index].typemod=target.damagestate.typemod
    # Type effectiveness
    if numhits>1
      if target.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      elsif target.damagestate.typemod>=1 && target.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
      if realnumhits==1
        @battle.pbDisplay(_INTL("Hit {1} time!",realnumhits))
      else
        @battle.pbDisplay(_INTL("Hit {1} times!",realnumhits))
      end
    end
    PBDebug.log("[#{numhits} hit(s), total damage=#{turneffects[PBEffects::TotalDamage]}]")
    # Faint if 0 HP
    target.pbFaint if target.isFainted? # no return
    user.pbFaint if user.isFainted? # no return
    # TODO: If Poison Point, etc. triggered above, user's Synchronize somehow triggers
    #       here even if condition is removed before now [true except for Triple Kick]
    # Destiny Bond
    if !user.isFainted? && target.isFainted?
      if destinybond && target.pbIsOpposing?(user.index)
        PBDebug.log("[#{target.pbThis}'s Destiny Bond triggered]")
        @battle.pbDisplay(_INTL("{1} took its attacker down with it!",target.pbThis))
        user.pbReduceHP(user.hp)
        user.pbFaint # no return
        @battle.pbJudgeCheckpoint(user)
      end
    end
    # Color Change
    movetype=thismove.pbType(thismove.type,user,target)
    if target.hasWorkingAbility(:COLORCHANGE) && totaldamage>0 &&
       !PBTypes.isPseudoType?(type) && !target.pbHasType?(movetype)
      target.type1=movetype
      target.type2=movetype
      @battle.pbDisplay(_INTL("{1}'s {2} made it the {3} type!",target.pbThis,
         PBAbilities.getName(target.ability),PBTypes.getName(movetype)))
      PBDebug.log("[#{target.pbThis}'s Color Change made it #{PBTypes.getName(movetype)}-type]")
    end
    # Berry check
    for j in 0...4
      @battle.battlers[j].pbBerryCureCheck
    end
    target.pbUpdateTargetedMove(thismove,user)
  end

  def pbUseMoveSimple(moveid,index=-1,target=-1)
    choice=[]
    choice[0]=1       # "Use move"
    choice[1]=index   # Index of move to be used in user's moveset
    choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(moveid)) # PokeBattle_Move object of the move
    choice[2].pp=-1
    choice[3]=target  # Target (-1 means no target yet)
    if index>=0
      @battle.choices[@index][1]=index
    end
    PBDebug.log("[#{pbThis}: used simple move choice[2].name]")
    @usingsubmove=true
    pbUseMove(choice,true)
    @usingsubmove=false
    return
  end

  def pbUseMove(choice,specialusage=false)
    # TODO: lastMoveUsed is not to be updated on nested calls
    turneffects=[]
    turneffects[PBEffects::SpecialUsage]=specialusage
    turneffects[PBEffects::PassedTrying]=false
    turneffects[PBEffects::TotalDamage]=0
    # Start using the move
    pbBeginTurn(choice)
    # Force the use of certain moves if they're already being used
    if @effects[PBEffects::TwoTurnAttack]>0 ||
       @effects[PBEffects::HyperBeam]>0 ||
       @effects[PBEffects::Outrage]>0 ||
       @effects[PBEffects::Rollout]>0 ||
       @effects[PBEffects::Uproar]>0 ||
       @effects[PBEffects::Bide]>0
      choice[2]=PokeBattle_Move.pbFromPBMove(@battle,PBMove.new(@currentMove))
      turneffects[PBEffects::SpecialUsage]=true
      PBDebug.log("[Continuing multi-turn move #{choice[2].name}]")
    elsif @effects[PBEffects::Encore]>0
      if @battle.pbCanShowCommands?(@index) &&
         @battle.pbCanChooseMove?(@index,@effects[PBEffects::EncoreIndex],false)
        if choice[1]!=@effects[PBEffects::EncoreIndex] # Was Encored mid-round
          choice[1]=@effects[PBEffects::EncoreIndex]
          choice[2]=@moves[@effects[PBEffects::EncoreIndex]]
          choice[3]=-1 # No target chosen
        end
        PBDebug.log("[Using Encored move #{choice[2].name}]")
      end
    end
    thismove=choice[2]
    return if !thismove || thismove.id==0 # if move was not chosen
    if !turneffects[PBEffects::SpecialUsage]
      # TODO: Quick Claw message
    end
    # TODO: Record that self has moved this round (for Payback, etc.)
    # Stance Change goes here
    # Try to use the move
    if !pbTryUseMove(choice,thismove,turneffects)
      self.lastMoveUsed=-1
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=-1
        self.lastRoundMoved=@battle.turncount
      end
      pbCancelMoves
      @battle.pbGainEXP
      pbEndTurn(choice)
      @battle.pbJudge #      @battle.pbSwitch
      return
    end
    if !turneffects[PBEffects::SpecialUsage]
      if !pbReducePP(thismove)
        @battle.pbDisplay(_INTL("{1} used\r\n{2}!",pbThis,thismove.name))
        @battle.pbDisplay(_INTL("But there was no PP left for the move!"))
        self.lastMoveUsed=-1
        if !turneffects[PBEffects::SpecialUsage]
          self.lastMoveUsedSketch=-1 if self.effects[PBEffects::TwoTurnAttack]==0
          self.lastRegularMoveUsed=-1
          self.lastRoundMoved=@battle.turncount
        end
        pbEndTurn(choice)
        @battle.pbJudge #        @battle.pbSwitch
        PBDebug.log("[#{thismove.name} has no PP left and can't be used]")
        return
      end
    end
    # Remember that user chose a two-turn move
    if thismove.pbTwoTurnAttack(self)
      # Beginning use of two-turn attack
      @effects[PBEffects::TwoTurnAttack]=thismove.id
      @currentMove=thismove.id
    else
      @effects[PBEffects::TwoTurnAttack]=0 # Cancel use of two-turn attack
    end
    # "X used Y!" message
    case thismove.pbDisplayUseMessage(self)
    when 2   # Continuing Bide
      if !turneffects[PBEffects::SpecialUsage]
        self.lastRoundMoved=@battle.turncount
      end
      PBDebug.log("[Continuing using Bide]")
      return
    when 1   # Starting Bide
      self.lastMoveUsed=thismove.id
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=thismove.id
        self.lastRoundMoved=@battle.turncount
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2
      @battle.successStates[self.index].typemod=4
      PBDebug.log("[Starting using Bide]")
      return
    when -1   # Was hurt while readying Focus Punch, fails use
      self.lastMoveUsed=thismove.id
      if !turneffects[PBEffects::SpecialUsage]
        self.lastMoveUsedSketch=thismove.id if self.effects[PBEffects::TwoTurnAttack]==0
        self.lastRegularMoveUsed=thismove.id
        self.lastRoundMoved=@battle.turncount
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=self.index
      @battle.successStates[self.index].useState=2 # somehow treated as a success
      @battle.successStates[self.index].typemod=4
      PBDebug.log("[#{pbThis} was hurt while readying Focus Punch and cancelled it]")
      return
    end
    # Find the user and target(s)
    targets=[]
    user=pbFindUser(choice,targets)
    # Battle Arena only - assume failure 
    @battle.successStates[user.index].useState=1
    @battle.successStates[user.index].typemod=4
    # Check whether Selfdestruct works
    selffaint=(thismove.function==0xE0) # Selfdestruct
    if !thismove.pbOnStartUse(user) # Only Selfdestruct can return false here
      PBDebug.log(sprintf("[Failed pbOnStartUse for function code %02X]",thismove.function))
      user.lastMoveUsed=thismove.id
      if !turneffects[PBEffects::SpecialUsage]
        user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
        user.lastRegularMoveUsed=thismove.id
        user.lastRoundMoved=@battle.turncount
      end
      @battle.lastMoveUsed=thismove.id
      @battle.lastMoveUser=user.index
      # Might pbEndTurn need to be called here?
      return
    end
    if selffaint
      user.hp=0
      user.pbFaint # no return
    end
    # Record move as having been used
    user.lastMoveUsed=thismove.id
    if !turneffects[PBEffects::SpecialUsage]
      user.lastMoveUsedSketch=thismove.id if user.effects[PBEffects::TwoTurnAttack]==0
      user.lastRegularMoveUsed=thismove.id
      user.movesUsed.push(thismove.id) if !user.movesUsed.include?(thismove.id) # For Last Resort
      user.lastRoundMoved=@battle.turncount
    end
    @battle.lastMoveUsed=thismove.id
    @battle.lastMoveUser=user.index
    # Try to use move against user if there aren't any targets
    if targets.length==0
      user=pbChangeUser(thismove,user)
      if thismove.target==PBTargets::SingleNonUser ||
         thismove.target==PBTargets::RandomOpposing ||
         thismove.target==PBTargets::AllOpposing ||
         thismove.target==PBTargets::AllNonUsers ||
         thismove.target==PBTargets::Partner ||
         thismove.target==PBTargets::UserOrPartner ||
         thismove.target==PBTargets::SingleOpposing ||
         thismove.target==PBTargets::OppositeOpposing
        @battle.pbDisplay(_INTL("But there was no target..."))
      else
        PBDebug.logonerr{
           thismove.pbEffect(user,nil)
        }
      end
    else
      # We have targets
      showanimation=true
      alltargets=[]
      for i in 0...targets.length
        alltargets.push(targets[i].index)
      end
      # For each target in turn
      i=0; loop do break if i>=targets.length
        # Get next target
        userandtarget=[user,targets[i]]
        success=pbChangeTarget(thismove,userandtarget,targets)
        user=userandtarget[0]
        target=userandtarget[1]
        if i==0 && thismove.target==PBTargets::AllOpposing
          # Add target's partner to list of targets
          pbAddTarget(targets,target.pbPartner)
        end
        # If couldn't get the next target
        if !success
          i+=1
          next
        end
        # Get the number of hits
        numhits=thismove.pbNumHits(user)
        # Reset damage state, set Focus Band/Focus Sash to available
        target.damagestate.reset
        if target.hasWorkingItem(:FOCUSBAND) && @battle.pbRandom(10)==0 
          target.damagestate.focusband=true
        end
        if target.hasWorkingItem(:FOCUSSASH)
          target.damagestate.focussash=true
        end
        # Use move against the current target
        pbProcessMoveAgainstTarget(thismove,user,target,numhits,turneffects,false,alltargets,showanimation)
        showanimation=false
        i+=1
      end
      # TODO: Sheer Force should prevent effects of items/abilities/moves that
      #       trigger here - which ones?
      if !(user.hasWorkingAbility(:SHEERFORCE) && thismove.addlEffect>0)
        # Shell Bell
        if user.hasWorkingItem(:SHELLBELL) && turneffects[PBEffects::TotalDamage]>0
          PBDebug.log("[#{user.pbThis}'s Shell Bell triggered (total damage=#{turneffects[PBEffects::TotalDamage]})]")
          hpgain=user.pbRecoverHP([(turneffects[PBEffects::TotalDamage]/8).floor,1].max,true)
          if hpgain>0
            @battle.pbDisplay(_INTL("{1} restored a little HP using its Shell Bell!",user.pbThis))
          end
        end
        # Life Orb
        if user.hasWorkingItem(:LIFEORB) && turneffects[PBEffects::TotalDamage]>0 &&
           !user.hasWorkingAbility(:MAGICGUARD)
          PBDebug.log("[#{user.pbThis}'s Life Orb triggered]")
          hploss=user.pbReduceHP([(user.totalhp/10).floor,1].min,true)
          if hploss>0
            @battle.pbDisplay(_INTL("{1} lost some of its HP!",user.pbThis))
          end
        end
        user.pbFaint if user.isFainted? # no return
      end
    end
    @battle.pbGainEXP
    # Battle Arena only - update skills
    for i in 0...4
      @battle.successStates[i].updateSkill
    end
    # End of move usage
    pbEndTurn(choice)
    @battle.pbJudge #    @battle.pbSwitch
    return
  end

  def pbCancelMoves
    # If failed pbTryUseMove or have already used Pursuit to chase a switching foe
    # Cancel multi-turn attacks (note: Hyper Beam effect is not canceled here)
    @effects[PBEffects::TwoTurnAttack]=0 if @effects[PBEffects::TwoTurnAttack]>0
    @effects[PBEffects::Outrage]=0
    @effects[PBEffects::Rollout]=0
    @effects[PBEffects::Uproar]=0
    @effects[PBEffects::Bide]=0
    @currentMove=0
    # Reset counters for moves which increase them when used in succession
    @effects[PBEffects::FuryCutter]=0
    @effects[PBEffects::EchoedVoice]=0
    PBDebug.log("[Cancelled using the move]")
  end

################################################################################
# Turn processing
################################################################################
  def pbBeginTurn(choice)
    # Cancel some lingering effects which only apply until the user next moves
    @effects[PBEffects::DestinyBond]=false
    @effects[PBEffects::Grudge]=false
    # Encore's effect ends if the encored move is no longer available
    if @effects[PBEffects::Encore]>0 &&
       @moves[@effects[PBEffects::EncoreIndex]].id!=@effects[PBEffects::EncoreMove]
      PBDebug.log("[Resetting Encore effect]")
      @effects[PBEffects::Encore]=0
      @effects[PBEffects::EncoreIndex]=0
      @effects[PBEffects::EncoreMove]=0
    end
    # Wake up in an uproar
    if self.status==PBStatuses::SLEEP && !self.hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          pbCureStatus(false)
          @battle.pbDisplay(_INTL("{1} woke up in the uproar!",pbThis))
        end
      end
    end
  end

  def pbEndTurn(choice)
    # True end(?)
    if @effects[PBEffects::ChoiceBand]<0 && @lastMoveUsed>=0 && !self.isFainted? && 
       (self.hasWorkingItem(:CHOICEBAND) ||
       self.hasWorkingItem(:CHOICESPECS) ||
       self.hasWorkingItem(:CHOICESCARF))
      @effects[PBEffects::ChoiceBand]=@lastMoveUsed
    end
    @battle.synchronize[0]=-1
    @battle.synchronize[1]=-1
    @battle.synchronize[2]=0
    for i in 0...4
      @battle.battlers[i].pbAbilityCureCheck
    end
    for i in 0...4
      @battle.battlers[i].pbBerryCureCheck
    end
    for i in 0...4
      @battle.battlers[i].pbAbilitiesOnSwitchIn(false)
    end
    for i in 0...4
      @battle.battlers[i].pbCheckForm
    end
  end

  def pbProcessTurn(choice)
    # Can't use a move if fainted
    return if self.isFainted?
    # Wild roaming Pokémon always flee if possible
    if !@battle.opponent && @battle.pbIsOpposing?(self.index) &&
       @battle.rules["alwaysflee"] && @battle.pbCanRun?(self.index)
      pbBeginTurn(choice)
      @battle.pbDisplay(_INTL("{1} fled!",self.pbThis))
      @battle.decision=3
      pbEndTurn(choice)
      PBDebug.log("[#{pbThis} fled]")
      return
    end
    # If this battler's action for this round wasn't "use a move"
    if choice[0]!=1
      # Clean up effects that end at battler's turn
      pbBeginTurn(choice)
      pbEndTurn(choice)
      return
    end
    # Turn is skipped if Pursuit was used during switch
    if @effects[PBEffects::Pursuit]
      @effects[PBEffects::Pursuit]=false
      pbCancelMoves
      pbEndTurn(choice)
      @battle.pbJudge #      @battle.pbSwitch
      return
    end
    # Use the move
#   @battle.pbDisplayPaused("Before: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
    PBDebug.log("[#{pbThis}: used choice[2].name]")
    PBDebug.logonerr{
       pbUseMove(choice,choice[2]==@battle.struggle)
    }
#   @battle.pbDisplayPaused("After: [#{@lastMoveUsedSketch},#{@lastMoveUsed}]")
  end
end