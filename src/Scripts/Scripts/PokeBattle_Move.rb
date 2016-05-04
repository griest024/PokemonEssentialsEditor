class PokeBattle_Move
  attr_accessor(:id)
  attr_reader(:battle)
  attr_reader(:name)
  attr_reader(:function)
  attr_reader(:basedamage)
  attr_reader(:type)
  attr_reader(:accuracy)
  attr_reader(:addlEffect)
  attr_reader(:target)
  attr_reader(:priority)
  attr_reader(:flags)
  attr_reader(:thismove)
  attr_accessor(:pp)
  attr_accessor(:totalpp)

  NOTYPE          = 0x01
  IGNOREPKMNTYPES = 0x02
  NOWEIGHTING     = 0x04
  NOCRITICAL      = 0x08
  NOREFLECT       = 0x10
  SELFCONFUSE     = 0x20

################################################################################
# Creating a move
################################################################################
  def initialize(battle,move)
    @id = move.id
    @battle = battle
    @name = PBMoves.getName(id)   # Get the move's name
    # Get data on the move
    movedata = PBMoveData.new(id)
    @function   = movedata.function
    @basedamage = movedata.basedamage
    @type       = movedata.type
    @accuracy   = movedata.accuracy
    @addlEffect = movedata.addlEffect
    @target     = movedata.target
    @priority   = movedata.priority
    @flags      = movedata.flags
    @category   = movedata.category
    @thismove   = move
    @pp         = move.pp   # Can be changed with Mimic/Transform
  end

# This is the code actually used to generate a PokeBattle_Move object.  The
# object generated is a subclass of this one which depends on the move's
# function code (found in the script section PokeBattle_MoveEffect).
  def PokeBattle_Move.pbFromPBMove(battle,move)
    move=PBMove.new(0) if !move
    movedata=PBMoveData.new(move.id)
    className=sprintf("PokeBattle_Move_%03X",movedata.function)
    if Object.const_defined?(className)
      return Kernel.const_get(className).new(battle,move)
    else
      return PokeBattle_UnimplementedMove.new(battle,move)
    end
  end

################################################################################
# About the move
################################################################################
  def totalpp
    return @totalpp if @totalpp && @totalpp>0
    return @thismove.totalpp if @thismove
  end

  def to_int
    return @id
  end

  def pbType(type,attacker,opponent)
    if type>=0 && attacker.hasWorkingAbility(:NORMALIZE)
      type=getConst(PBTypes,:NORMAL) || 0
    end
    return type
  end

  def pbIsPhysical?(type)
    if USEMOVECATEGORY
      return @category==0
    else
      return !PBTypes.isSpecialType?(type)
    end
  end

  def pbIsSpecial?(type)
    if USEMOVECATEGORY
      return @category==1
    else
      return PBTypes.isSpecialType?(type)
    end
  end

  def pbTargetsAll?(attacker)
    if @target==PBTargets::AllOpposing
      # TODO: should apply even if partner faints during an attack
      numtargets=0
      numtargets+=1 if !attacker.pbOpposing1.isFainted?
      numtargets+=1 if !attacker.pbOpposing2.isFainted?
      return numtargets>1
    elsif @target==PBTargets::AllNonUsers
      # TODO: should apply even if partner faints during an attack
      numtargets=0
      numtargets+=1 if !attacker.pbOpposing1.isFainted?
      numtargets+=1 if !attacker.pbOpposing2.isFainted?
      numtargets+=1 if !attacker.pbPartner.isFainted?
      return numtargets>1
    end
    return false
  end

  def pbNumHits(attacker)
    # Parental Bond goes here (for single target moves only)
    # Need to record that Parental Bond applies, to weaken the second attack
    return 1
  end

  def pbIsMultiHit   # not the same as pbNumHits>1
    return false
  end

  def pbTwoTurnAttack(attacker,checking=false)
    return false
  end

  def pbAdditionalEffect(attacker,opponent)
  end

  def pbCanUseWhileAsleep?
    return false
  end

  def isContactMove?
    return (@flags&0x01)!=0 # flag a: Makes contact
  end

  def canProtectAgainst?
    return (@flags&0x02)!=0 # flag b: Protect/Detect
  end

  def canMagicCoat?
    return (@flags&0x04)!=0 # flag c: Magic Coat
  end

  def canSnatch?
    return (@flags&0x08)!=0 # flag d: Snatch
  end

  def canMirrorMove? # This method isn't used
    return (@flags&0x10)!=0 # flag e: Copyable by Mirror Move
  end

  def canKingsRock?
    return (@flags&0x20)!=0 # flag f: King's Rock
  end

  def canThawUser?
    return (@flags&0x40)!=0 # flag g: Thaws user before moving
  end

  def hasHighCriticalRate?
    return (@flags&0x80)!=0 # flag h: Has high critical hit rate
  end

  def isHealingMove?
    return (@flags&0x100)!=0 # flag i: Is healing move
  end

  def isPunchingMove?
    return (@flags&0x200)!=0 # flag j: Is punching move
  end

  def isSoundBased?
    return (@flags&0x400)!=0 # flag k: Is sound-based move
  end

  def unusableInGravity?
    return (@flags&0x800)!=0 # flag l: Can't use in Gravity
  end

################################################################################
# This move's type effectiveness
################################################################################
  def pbTypeModifier(type,attacker,opponent)
    return 4 if type<0
    return 4 if isConst?(type,PBTypes,:GROUND) && opponent.pbHasType?(:FLYING) &&
                opponent.hasWorkingItem(:IRONBALL)
    atype=type # attack type
    otype1=opponent.type1
    otype2=opponent.type2
    if isConst?(otype1,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      if isConst?(otype2,PBTypes,:FLYING)
        otype1=getConst(PBTypes,:NORMAL) || 0
      else
        otype1=otype2
      end
    end
    if isConst?(otype2,PBTypes,:FLYING) && opponent.effects[PBEffects::Roost]
      otype2=otype1
    end
    mod1=PBTypes.getEffectiveness(atype,otype1)
    mod2=(otype1==otype2) ? 2 : PBTypes.getEffectiveness(atype,otype2)
    if opponent.hasWorkingItem(:RINGTARGET)
      mod1=2 if mod1==0
      mod2=2 if mod2==0
    end
    if attacker.hasWorkingAbility(:SCRAPPY) ||
      opponent.effects[PBEffects::Foresight]
      mod1=2 if isConst?(otype1,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
      mod2=2 if isConst?(otype2,PBTypes,:GHOST) &&
        (isConst?(atype,PBTypes,:NORMAL) || isConst?(atype,PBTypes,:FIGHTING))
    end
    if opponent.effects[PBEffects::Ingrain] ||
       opponent.effects[PBEffects::SmackDown] ||
       @battle.field.effects[PBEffects::Gravity]>0
      mod1=2 if isConst?(otype1,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
      mod2=2 if isConst?(otype2,PBTypes,:FLYING) && isConst?(atype,PBTypes,:GROUND)
    end
    if opponent.effects[PBEffects::MiracleEye]
      mod1=2 if isConst?(otype1,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
      mod2=2 if isConst?(otype2,PBTypes,:DARK) && isConst?(atype,PBTypes,:PSYCHIC)
    end
    return mod1*mod2
  end

  def pbTypeModMessages(type,attacker,opponent)
    return 4 if type<0
    if opponent.hasWorkingAbility(:SAPSIPPER) && isConst?(type,PBTypes,:GRASS)
      PBDebug.log("[#{opponent.pbThis}'s Sap Sipper triggered and made #{@name} ineffective]")
      if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
        opponent.pbIncreaseStatBasic(PBStats::ATTACK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Attack!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if (opponent.hasWorkingAbility(:STORMDRAIN) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:LIGHTNINGROD) && isConst?(type,PBTypes,:ELECTRIC))
      PBDebug.log("[#{opponent.pbThis}'s #{PBAbilities.getName(opponent.ability)} triggered and made #{@name} ineffective]")
      if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
        opponent.pbIncreaseStatBasic(PBStats::SPATK,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Special Attack!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if opponent.hasWorkingAbility(:MOTORDRIVE) && isConst?(type,PBTypes,:ELECTRIC)
      PBDebug.log("[#{opponent.pbThis}'s Motor Drive triggered and made #{@name} ineffective]")
      if opponent.pbCanIncreaseStatStage?(PBStats::SPEED)
        opponent.pbIncreaseStatBasic(PBStats::SPEED,1)
        @battle.pbCommonAnimation("StatUp",opponent,nil)
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Speed!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    if (opponent.hasWorkingAbility(:DRYSKIN) && isConst?(type,PBTypes,:WATER)) ||
       (opponent.hasWorkingAbility(:VOLTABSORB) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (opponent.hasWorkingAbility(:WATERABSORB) && isConst?(type,PBTypes,:WATER))
      PBDebug.log("[#{opponent.pbThis}'s #{PBAbilities.getName(opponent.ability)} triggered and made #{@name} ineffective]")
      if opponent.effects[PBEffects::HealBlock]==0
        if opponent.pbRecoverHP((opponent.totalhp/4).floor,true)>0
          @battle.pbDisplay(_INTL("{1}'s {2} restored its HP!",
             opponent.pbThis,PBAbilities.getName(opponent.ability)))
        else
          @battle.pbDisplay(_INTL("{1}'s {2} made {3} useless!",
             opponent.pbThis,PBAbilities.getName(opponent.ability),@name))
        end
        return 0
      end
    end
    if opponent.hasWorkingAbility(:FLASHFIRE) && isConst?(type,PBTypes,:FIRE)
      PBDebug.log("[#{opponent.pbThis}'s Flash Fire triggered and made #{@name} ineffective]")
      if !opponent.effects[PBEffects::FlashFire]
        opponent.effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",
           opponent.pbThis,PBAbilities.getName(opponent.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",
           opponent.pbThis,PBAbilities.getName(opponent.ability),self.name))
      end
      return 0
    end
    typemod=pbTypeModifier(type,attacker,opponent)
    if typemod==0
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
    end
    return typemod
  end

################################################################################
# This move's accuracy check
################################################################################
  def pbAccuracyCheck(attacker,opponent)
    baseaccuracy=@accuracy
    return true if baseaccuracy==0
    return true if attacker.hasWorkingAbility(:NOGUARD) ||
                   opponent.hasWorkingAbility(:NOGUARD)
    return true if opponent.effects[PBEffects::Telekinesis]>0
    return true if @function==0x0D && @battle.pbWeather==PBWeather::HAIL # Blizzard
    return true if (@function==0x08 || @function==0x15) && # Thunder, Hurricane
                   @battle.pbWeather==PBWeather::RAINDANCE
    # One-hit KO accuracy handled elsewhere
    if @function==0x08 || @function==0x15 # Thunder, Hurricane
      baseaccuracy=50 if @battle.pbWeather==PBWeather::SUNNYDAY
    end
    accstage=attacker.stages[PBStats::ACCURACY]
    accstage=0 if opponent.hasWorkingAbility(:UNAWARE)
    accuracy=(accstage>=0) ? (accstage+3)*100.0/3 : 300.0/(3-accstage)
    evastage=opponent.stages[PBStats::EVASION]
    evastage-=2 if @battle.field.effects[PBEffects::Gravity]>0
    evastage=-6 if evastage<-6
    evastage=0 if opponent.effects[PBEffects::Foresight] ||
                  opponent.effects[PBEffects::MiracleEye] ||
                  @function==0xA9 || # Chip Away
                  attacker.hasWorkingAbility(:UNAWARE)
    evasion=(evastage>=0) ? (evastage+3)*100.0/3 : 300.0/(3-evastage)
    if attacker.hasWorkingAbility(:COMPOUNDEYES)
      accuracy*=1.3
    end
    if attacker.hasWorkingItem(:MICLEBERRY)
      if (attacker.hasWorkingAbility(:GLUTTONY) && attacker.hp<=(attacker.totalhp/2).floor) ||
         attacker.hp<=(attacker.totalhp/4).floor
        PBDebug.log("[#{attacker.pbThis} consumed its #{PBItems.getName(attacker.item)}]")
        accuracy*=1.2
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
      end
    end
    if attacker.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    partner=attacker.pbPartner
    if partner && partner.hasWorkingAbility(:VICTORYSTAR)
      accuracy*=1.1
    end
    if attacker.hasWorkingItem(:WIDELENS)
      accuracy*=1.1
    end
    if attacker.hasWorkingAbility(:HUSTLE) && @basedamage>0 &&
       pbIsPhysical?(pbType(@type,attacker,opponent))
      accuracy*=0.8
    end
    if opponent.hasWorkingAbility(:WONDERSKIN) && @basedamage==0 &&
       attacker.pbIsOpposing?(opponent.index)
      accuracy/=2
    end
    if opponent.hasWorkingAbility(:TANGLEDFEET) &&
       opponent.effects[PBEffects::Confusion]>0
      evasion*=1.2
    end
    if opponent.hasWorkingAbility(:SANDVEIL) &&
       @battle.pbWeather==PBWeather::SANDSTORM
      evasion*=1.2
    end
    if opponent.hasWorkingAbility(:SNOWCLOAK) &&
       @battle.pbWeather==PBWeather::HAIL
      evasion*=1.2
    end
    if opponent.hasWorkingItem(:BRIGHTPOWDER)
      evasion*=1.1
    end
    if opponent.hasWorkingItem(:LAXINCENSE)
      evasion*=1.1
    end
    return @battle.pbRandom(100)<(baseaccuracy*accuracy/evasion)
  end

################################################################################
# Damage calculation and modifiers
################################################################################
  def pbIsCritical?(attacker,opponent)
    if opponent.hasWorkingAbility(:BATTLEARMOR) ||
       opponent.hasWorkingAbility(:SHELLARMOR)
      return false
    end
    return false if opponent.pbOwnSide.effects[PBEffects::LuckyChant]>0
    return true if @function==0xA0 # Frost Breath
    c=0
    ratios=[16,8,4,3,2]
    c+=attacker.effects[PBEffects::FocusEnergy]
    c+=1 if hasHighCriticalRate?
    if (attacker.inHyperMode? rescue false) && isConst?(self.type,PBTypes,:SHADOW)
      c+=1
    end
    c+=1 if attacker.hasWorkingAbility(:SUPERLUCK)
    if attacker.hasWorkingItem(:STICK) &&
       isConst?(attacker.species,PBSpecies,:FARFETCHD)
      c+=2
    end
    if attacker.hasWorkingItem(:LUCKYPUNCH) &&
       isConst?(attacker.species,PBSpecies,:CHANSEY)
      c+=2
    end
    c+=1 if attacker.hasWorkingItem(:RAZORCLAW)
    c+=1 if attacker.hasWorkingItem(:SCOPELENS)
    c=4 if c>4
    return @battle.pbRandom(ratios[c])==0
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    return damagemult
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    return damagemult
  end

  def pbCalcDamage(attacker,opponent,options=0)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    return 0 if @basedamage==0
    if (options&NOCRITICAL)==0
      opponent.damagestate.critical=pbIsCritical?(attacker,opponent)
    end
    stagemul=[2,2,2,2,2,2,2,3,4,5,6,7,8]
    stagediv=[8,7,6,5,4,3,2,2,2,2,2,2,2]
    if (options&NOTYPE)==0
      type=pbType(@type,attacker,opponent)
    else
      type=-1 # Will be treated as physical
    end
    ##### Calcuate base power of move #####
    basedmg=@basedamage # Fron PBS file
    basedmg=pbBaseDamage(basedmg,attacker,opponent) # Some function codes alter base power
    damagemult=0x1000
    if attacker.hasWorkingAbility(:TECHNICIAN) && basedmg<=60
      damagemult=(damagemult*1.5).round
    end
    if attacker.hasWorkingAbility(:IRONFIST) && isPunchingMove?
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingAbility(:RECKLESS)
      if @function==0xFA ||  # Take Down, etc.
         @function==0xFB ||  # Double-Edge, etc.
         @function==0xFC ||  # Head Smash
         @function==0xFD ||  # Volt Tackle
         @function==0xFE ||  # Flare Blitz
         @function==0x10B || # Jump Kick, Hi Jump Kick
         @function==0x130    # Shadow End
        damagemult=(damagemult*1.2).round
      end
    end
    if attacker.hasWorkingAbility(:FLAREBOOST) &&
       attacker.status==PBStatuses::BURN && pbIsSpecial?(type)
      damagemult=(damagemult*1.5).round
    end
    if attacker.hasWorkingAbility(:TOXICBOOST) &&
       attacker.status==PBStatuses::POISON && pbIsPhysical?(type)
      damagemult=(damagemult*1.5).round
    end
    #if attacker.hasWorkingAbility(:ANALYTIC) &&
    #   move isn't Future Sight/Doom Desire && target has already moved this turn
    #  damagemult=(damagemult*1.3).round
    #end
    if attacker.hasWorkingAbility(:RIVALRY) &&
       attacker.gender!=2 && opponent.gender!=2
      if attacker.gender==opponent.gender
        damagemult=(damagemult*1.25).round
      else
        damagemult=(damagemult*0.75).round
      end
    end
    if attacker.hasWorkingAbility(:SANDFORCE) &&
       @battle.pbWeather==PBWeather::SANDSTORM &&
       (isConst?(type,PBTypes,:ROCK) ||
       isConst?(type,PBTypes,:GROUND) ||
       isConst?(type,PBTypes,:STEEL))
      damagemult=(damagemult*1.3).round
    end
    if opponent.hasWorkingAbility(:HEATPROOF) && isConst?(type,PBTypes,:FIRE)
      damagemult=(damagemult*0.5).round
    end
    if opponent.hasWorkingAbility(:DRYSKIN) && isConst?(type,PBTypes,:FIRE)
      damagemult=(damagemult*1.25).round
    end
    if attacker.hasWorkingAbility(:SHEERFORCE) && @addlEffect>0
      damagemult=(damagemult*1.3).round
    end
    if (attacker.hasWorkingItem(:SILKSCARF) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:BLACKBELT) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SHARPBEAK) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONBARB) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:SOFTSAND) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:HARDSTONE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:SILVERPOWDER) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPELLTAG) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:METALCOAT) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:CHARCOAL) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:MYSTICWATER) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MIRACLESEED) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:MAGNET) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:TWISTEDSPOON) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:NEVERMELTICE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONFANG) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:BLACKGLASSES) && isConst?(type,PBTypes,:DARK))
      damagemult=(damagemult*1.2).round
    end
    if (attacker.hasWorkingItem(:FISTPLATE) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:SKYPLATE) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:TOXICPLATE) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:EARTHPLATE) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:STONEPLATE) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:INSECTPLATE) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:SPOOKYPLATE) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:IRONPLATE) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FLAMEPLATE) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:SPLASHPLATE) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:MEADOWPLATE) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ZAPPLATE) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:MINDPLATE) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICICLEPLATE) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRACOPLATE) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DREADPLATE) && isConst?(type,PBTypes,:DARK))
      damagemult=(damagemult*1.2).round
    end
    if (attacker.hasWorkingItem(:NORMALGEM) && isConst?(type,PBTypes,:NORMAL)) ||
       (attacker.hasWorkingItem(:FIGHTINGGEM) && isConst?(type,PBTypes,:FIGHTING)) ||
       (attacker.hasWorkingItem(:FLYINGGEM) && isConst?(type,PBTypes,:FLYING)) ||
       (attacker.hasWorkingItem(:POISONGEM) && isConst?(type,PBTypes,:POISON)) ||
       (attacker.hasWorkingItem(:GROUNDGEM) && isConst?(type,PBTypes,:GROUND)) ||
       (attacker.hasWorkingItem(:ROCKGEM) && isConst?(type,PBTypes,:ROCK)) ||
       (attacker.hasWorkingItem(:BUGGEM) && isConst?(type,PBTypes,:BUG)) ||
       (attacker.hasWorkingItem(:GHOSTGEM) && isConst?(type,PBTypes,:GHOST)) ||
       (attacker.hasWorkingItem(:STEELGEM) && isConst?(type,PBTypes,:STEEL)) ||
       (attacker.hasWorkingItem(:FIREGEM) && isConst?(type,PBTypes,:FIRE)) ||
       (attacker.hasWorkingItem(:WATERGEM) && isConst?(type,PBTypes,:WATER)) ||
       (attacker.hasWorkingItem(:GRASSGEM) && isConst?(type,PBTypes,:GRASS)) ||
       (attacker.hasWorkingItem(:ELECTRICGEM) && isConst?(type,PBTypes,:ELECTRIC)) ||
       (attacker.hasWorkingItem(:PSYCHICGEM) && isConst?(type,PBTypes,:PSYCHIC)) ||
       (attacker.hasWorkingItem(:ICEGEM) && isConst?(type,PBTypes,:ICE)) ||
       (attacker.hasWorkingItem(:DRAGONGEM) && isConst?(type,PBTypes,:DRAGON)) ||
       (attacker.hasWorkingItem(:DARKGEM) && isConst?(type,PBTypes,:DARK))
      PBDebug.log("[#{attacker.pbThis} consumed its #{PBItems.getName(attacker.item)}]")
      damagemult=(damagemult*1.5).round
      attacker.pokemon.itemRecycle=attacker.item
      attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
      attacker.item=0
    end
    if attacker.hasWorkingItem(:ROCKINCENSE) && isConst?(type,PBTypes,:ROCK)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:ROSEINCENSE) && isConst?(type,PBTypes,:GRASS)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:SEAINCENSE) && isConst?(type,PBTypes,:WATER)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:WAVEINCENSE) && isConst?(type,PBTypes,:WATER)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:ODDINCENSE) && isConst?(type,PBTypes,:PSYCHIC)
      damagemult=(damagemult*1.2).round
    end
    if attacker.hasWorkingItem(:MUSCLEBAND) && pbIsPhysical?(type)
      damagemult=(damagemult*1.1).round
    end
    if attacker.hasWorkingItem(:WISEGLASSES) && pbIsSpecial?(type)
      damagemult=(damagemult*1.1).round
    end
    if isConst?(attacker.species,PBSpecies,:PALKIA) &&
       attacker.hasWorkingItem(:LUSTROUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:WATER))
      damagemult=(damagemult*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:DIALGA) &&
       attacker.hasWorkingItem(:ADAMANTORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:STEEL))
      damagemult=(damagemult*1.2).round
    end
    if isConst?(attacker.species,PBSpecies,:GIRATINA) &&
       attacker.hasWorkingItem(:GRISEOUSORB) &&
       (isConst?(type,PBTypes,:DRAGON) || isConst?(type,PBTypes,:GHOST))
      damagemult=(damagemult*1.2).round
    end
    damagemult=pbBaseDamageMultiplier(damagemult,attacker,opponent)
    #if move was called using Me First
    #  damagemult=(damagemult*1.5).round
    #end
    if attacker.effects[PBEffects::Charge]>0 && isConst?(type,PBTypes,:ELECTRIC)
      damagemult=(damagemult*2.0).round
    end
    if attacker.effects[PBEffects::HelpingHand] && (options&SELFCONFUSE)==0
      damagemult=(damagemult*1.5).round
    end
    if isConst?(type,PBTypes,:FIRE)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::WaterSport] && !@battle.battlers[i].isFainted?
          damagemult=(damagemult*0.33).round
          break
        end
      end
    end
    if isConst?(type,PBTypes,:ELECTRIC)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::MudSport] && !@battle.battlers[i].isFainted?
          damagemult=(damagemult*0.33).round
          break
        end
      end
    end
    basedmg=(basedmg*damagemult*1.0/0x1000).round
    ##### Calculate attacker's attack stat #####
    atk=attacker.attack
    atkstage=attacker.stages[PBStats::ATTACK]+6
    if @function==0x121 # Foul Play
      atk=opponent.attack
      atkstage=opponent.stages[PBStats::ATTACK]+6
    end
    if type>=0 && pbIsSpecial?(type)
      atk=attacker.spatk
      atkstage=attacker.stages[PBStats::SPATK]+6
      if @function==0x121 # Foul Play
        atk=opponent.spatk
        atkstage=opponent.stages[PBStats::SPATK]+6
      end
    end
    if !opponent.hasWorkingAbility(:UNAWARE)
      atkstage=6 if opponent.damagestate.critical && atkstage<6
      atk=(atk*1.0*stagemul[atkstage]/stagediv[atkstage]).floor
    end
    if attacker.hasWorkingAbility(:HUSTLE) && pbIsPhysical?(type)
      atk=(atk*1.5).round
    end
    atkmult=0x1000
    if @battle.internalbattle
      if @battle.pbOwnedByPlayer?(attacker.index) && pbIsPhysical?(type) &&
         @battle.pbPlayer.numbadges>=BADGESBOOSTATTACK
        atkmult=(atkmult*1.1).round
      end
      if @battle.pbOwnedByPlayer?(attacker.index) && pbIsSpecial?(type) &&
         @battle.pbPlayer.numbadges>=BADGESBOOSTSPATK
        atkmult=(atkmult*1.1).round
      end
    end
    if opponent.hasWorkingAbility(:THICKFAT) &&
       (isConst?(type,PBTypes,:ICE) || isConst?(type,PBTypes,:FIRE))
      atkmult=(atkmult*0.5).round
    end
    if attacker.hp<=(attacker.totalhp/3).floor
      if (attacker.hasWorkingAbility(:OVERGROW) && isConst?(type,PBTypes,:GRASS)) ||
         (attacker.hasWorkingAbility(:BLAZE) && isConst?(type,PBTypes,:FIRE)) ||
         (attacker.hasWorkingAbility(:TORRENT) && isConst?(type,PBTypes,:WATER)) ||
         (attacker.hasWorkingAbility(:SWARM) && isConst?(type,PBTypes,:BUG))
      atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingAbility(:GUTS) &&
       attacker.status!=0 && pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if (attacker.hasWorkingAbility(:PLUS) || attacker.hasWorkingAbility(:MINUS)) &&
       pbIsSpecial?(type)
      partner=attacker.pbPartner
      if partner.hasWorkingAbility(:PLUS) || partner.hasWorkingAbility(:MINUS)
        atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingAbility(:DEFEATIST) &&
       attacker.hp<=(attacker.totalhp/2).floor
      atkmult=(atkmult*0.5).round
    end
    if attacker.hasWorkingAbility(:PUREPOWER) ||
       attacker.hasWorkingAbility(:HUGEPOWER)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingAbility(:SOLARPOWER) &&
       @battle.pbWeather==PBWeather::SUNNYDAY && pbIsSpecial?(type)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingAbility(:FLASHFIRE) &&
       attacker.effects[PBEffects::FlashFire] && isConst?(type,PBTypes,:FIRE)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingAbility(:SLOWSTART) &&
       attacker.turncount<5 && pbIsPhysical?(type)
      atkmult=(atkmult*0.5).round
    end
    if @battle.pbWeather==PBWeather::SUNNYDAY && pbIsPhysical?(type)
      if attacker.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(attacker.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
      if attacker.pbPartner.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(attacker.pbPartner.species,PBSpecies,:CHERRIM)
        atkmult=(atkmult*1.5).round
      end
    end
    if attacker.hasWorkingItem(:THICKCLUB) &&
       (isConst?(attacker.species,PBSpecies,:CUBONE) ||
       isConst?(attacker.species,PBSpecies,:MAROWAK)) && pbIsPhysical?(type)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingItem(:DEEPSEATOOTH) &&
       isConst?(attacker.species,PBSpecies,:CLAMPERL) && pbIsSpecial?(type)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingItem(:LIGHTBALL) &&
       isConst?(attacker.species,PBSpecies,:PIKACHU)
      atkmult=(atkmult*2.0).round
    end
    if attacker.hasWorkingItem(:SOULDEW) &&
       (isConst?(attacker.species,PBSpecies,:LATIAS) ||
       isConst?(attacker.species,PBSpecies,:LATIOS)) && pbIsSpecial?(type) &&
       !@battle.rules["souldewclause"]
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICEBAND) && pbIsPhysical?(type)
      atkmult=(atkmult*1.5).round
    end
    if attacker.hasWorkingItem(:CHOICESPECS) && pbIsSpecial?(type)
      atkmult=(atkmult*1.5).round
    end
    atk=(atk*atkmult*1.0/0x1000).round
    ##### Calculate opponent's defense stat #####
    defense=opponent.defense
    defstage=opponent.stages[PBStats::DEFENSE]+6
    # TODO: Wonder Room should apply around here
    applysandstorm=false
    if type>=0 && pbIsSpecial?(type) && @function!=0x122 # Psyshock
      defense=opponent.spdef
      defstage=opponent.stages[PBStats::SPDEF]+6
      applysandstorm=true
    end
    if !attacker.hasWorkingAbility(:UNAWARE)
      defstage=6 if @function==0xA9 # Chip Away (ignore stat stages)
      defstage=6 if opponent.damagestate.critical && defstage>6
      defense=(defense*1.0*stagemul[defstage]/stagediv[defstage]).floor
    end
    if @battle.pbWeather==PBWeather::SANDSTORM &&
       opponent.pbHasType?(:ROCK) && applysandstorm
      defense=(defense*1.5).round
    end
    defmult=0x1000
    if @battle.internalbattle
      if @battle.pbOwnedByPlayer?(opponent.index) && pbIsPhysical?(type) &&
         @battle.pbPlayer.numbadges>=BADGESBOOSTDEFENSE
        defmult=(defmult*1.1).round
      end
      if @battle.pbOwnedByPlayer?(opponent.index) && pbIsSpecial?(type) &&
         @battle.pbPlayer.numbadges>=BADGESBOOSTSPDEF
        defmult=(defmult*1.1).round
      end
    end
    if opponent.hasWorkingAbility(:MARVELSCALE) &&
       opponent.status>0 && pbIsPhysical?(type)
      defmult=(defmult*1.5).round
    end
    if @battle.pbWeather==PBWeather::SUNNYDAY && pbIsSpecial?(type)
      if opponent.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(opponent.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
      if opponent.pbPartner.hasWorkingAbility(:FLOWERGIFT) &&
         isConst?(opponent.pbPartner.species,PBSpecies,:CHERRIM)
        defmult=(defmult*1.5).round
      end
    end
    if opponent.hasWorkingItem(:EVIOLITE)
      evos=pbGetEvolvedFormData(opponent.species)
      if evos && evos.length>0
        defmult=(defmult*1.5).round
      end
    end
    if opponent.hasWorkingItem(:DEEPSEASCALE) &&
       isConst?(opponent.species,PBSpecies,:CLAMPERL) && pbIsSpecial?(type)
      defmult=(defmult*2.0).round
    end
    if opponent.hasWorkingItem(:METALPOWDER) &&
       isConst?(opponent.species,PBSpecies,:DITTO) &&
       !opponent.effects[PBEffects::Transform] && pbIsPhysical?(type)
      defmult=(defmult*2.0).round
    end
    if opponent.hasWorkingItem(:SOULDEW) &&
       (isConst?(opponent.species,PBSpecies,:LATIAS) ||
       isConst?(opponent.species,PBSpecies,:LATIOS)) && pbIsSpecial?(type) &&
       !@battle.rules["souldewclause"]
      defmult=(defmult*1.5).round
    end
    defense=(defense*defmult*1.0/0x1000).round
    ##### Main damage calculation #####
    damage=(((2.0*attacker.level/5+2).floor*basedmg*atk/defense).floor/50).floor+2
    # Multi-targeting attacks
    if pbTargetsAll?(attacker)
      damage=(damage*0.75).round
    end
    # Weather
    case @battle.pbWeather
    when PBWeather::SUNNYDAY
      if isConst?(type,PBTypes,:FIRE)
        damage=(damage*1.5).round
      elsif isConst?(type,PBTypes,:WATER)
        damage=(damage*0.5).round
      end
    when PBWeather::RAINDANCE
      if isConst?(type,PBTypes,:FIRE)
        damage=(damage*0.5).round
      elsif isConst?(type,PBTypes,:WATER)
        damage=(damage*1.5).round
      end
    end
    # Critical hits
    if opponent.damagestate.critical
      damage=(damage*2.0).round
    end
    # Random variance
    if (options&NOWEIGHTING)==0
      random=85+@battle.pbRandom(16)
      damage=(damage*random/100.0).floor
    end
    # STAB
    if attacker.pbHasType?(type) && (options&IGNOREPKMNTYPES)==0
      if attacker.hasWorkingAbility(:ADAPTABILITY)
        damage=(damage*2).round
      else
        damage=(damage*1.5).round
      end
    end
    # Type effectiveness
    if (options&IGNOREPKMNTYPES)==0
      typemod=pbTypeModMessages(type,attacker,opponent)
      damage=(damage*typemod/4.0).round
      opponent.damagestate.typemod=typemod
      if typemod==0
        opponent.damagestate.calcdamage=0
        opponent.damagestate.critical=false
        return 0
      end
    else
      opponent.damagestate.typemod=4
    end
    # Burn
    if attacker.status==PBStatuses::BURN && pbIsPhysical?(type) &&
       !attacker.hasWorkingAbility(:GUTS)
      damage=(damage*0.5).round
    end
    # Make sure damage is at least 1
    damage=1 if damage<1
    # Final damage modifiers
    finaldamagemult=0x1000
    if !opponent.damagestate.critical && (options&NOREFLECT)==0 &&
       !attacker.hasWorkingAbility(:INFILTRATOR)
      # Reflect
      if opponent.pbOwnSide.effects[PBEffects::Reflect]>0 && pbIsPhysical?(type)
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted?
          finaldamagemult=(finaldamagemult*0.66).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
      end
      # Light Screen
      if opponent.pbOwnSide.effects[PBEffects::LightScreen]>0 && pbIsSpecial?(type)
        # TODO: should apply even if partner faints during an attack]
        if !opponent.pbPartner.isFainted?
          finaldamagemult=(finaldamagemult*0.66).round
        else
          finaldamagemult=(finaldamagemult*0.5).round
        end
      end
    end
    if opponent.hasWorkingAbility(:MULTISCALE) &&
       opponent.hp==opponent.totalhp
      finaldamagemult=(finaldamagemult*0.5).round
    end
    if opponent.hasWorkingAbility(:TINTEDLENS) &&
       opponent.damagestate.typemod<4
      finaldamagemult=(finaldamagemult*2.0).round
    end
    if opponent.pbPartner.hasWorkingAbility(:FRIENDGUARD)
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if attacker.hasWorkingAbility(:SNIPER) && opponent.damagestate.critical
      finaldamagemult=(finaldamagemult*1.5).round
    end
    if (opponent.hasWorkingAbility(:SOLIDROCK) ||
       opponent.hasWorkingAbility(:FILTER)) &&
       opponent.damagestate.typemod>4
      finaldamagemult=(finaldamagemult*0.75).round
    end
    if attacker.hasWorkingItem(:METRONOME)
      if attacker.effects[PBEffects::Metronome]>4
        finaldamagemult=(finaldamagemult*2.0).round
      else
        met=1.0+attacker.effects[PBEffects::Metronome]*0.2
        finaldamagemult=(finaldamagemult*met).round
      end
    end
    if attacker.hasWorkingItem(:EXPERTBELT) &&
       opponent.damagestate.typemod>4
      finaldamagemult=(finaldamagemult*1.2).round
    end
    if attacker.hasWorkingItem(:LIFEORB)
      finaldamagemult=(finaldamagemult*1.3).round
    end
    if opponent.damagestate.typemod>4 && (options&IGNOREPKMNTYPES)==0
      if (opponent.hasWorkingItem(:CHOPLEBERRY) && isConst?(type,PBTypes,:FIGHTING)) ||
         (opponent.hasWorkingItem(:COBABERRY) && isConst?(type,PBTypes,:FLYING)) ||
         (opponent.hasWorkingItem(:KEBIABERRY) && isConst?(type,PBTypes,:POISON)) ||
         (opponent.hasWorkingItem(:SHUCABERRY) && isConst?(type,PBTypes,:GROUND)) ||
         (opponent.hasWorkingItem(:CHARTIBERRY) && isConst?(type,PBTypes,:ROCK)) ||
         (opponent.hasWorkingItem(:TANGABERRY) && isConst?(type,PBTypes,:BUG)) ||
         (opponent.hasWorkingItem(:KASIBBERRY) && isConst?(type,PBTypes,:GHOST)) ||
         (opponent.hasWorkingItem(:BABIRIBERRY) && isConst?(type,PBTypes,:STEEL)) ||
         (opponent.hasWorkingItem(:OCCABERRY) && isConst?(type,PBTypes,:FIRE)) ||
         (opponent.hasWorkingItem(:PASSHOBERRY) && isConst?(type,PBTypes,:WATER)) ||
         (opponent.hasWorkingItem(:RINDOBERRY) && isConst?(type,PBTypes,:GRASS)) ||
         (opponent.hasWorkingItem(:WACANBERRY) && isConst?(type,PBTypes,:ELECTRIC)) ||
         (opponent.hasWorkingItem(:PAYAPABERRY) && isConst?(type,PBTypes,:PSYCHIC)) ||
         (opponent.hasWorkingItem(:YACHEBERRY) && isConst?(type,PBTypes,:ICE)) ||
         (opponent.hasWorkingItem(:HABANBERRY) && isConst?(type,PBTypes,:DRAGON)) ||
         (opponent.hasWorkingItem(:COLBURBERRY) && isConst?(type,PBTypes,:DARK))
        PBDebug.log("[#{opponent.pbThis} consumed its #{PBItems.getName(opponent.item)}]")
        finaldamagemult=(finaldamagemult*0.5).round
        opponent.pokemon.itemRecycle=opponent.item
        opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
        opponent.item=0
      end
    end
    if opponent.hasWorkingItem(:CHILANBERRY) && isConst?(type,PBTypes,:NORMAL) &&
       (options&IGNOREPKMNTYPES)==0
      PBDebug.log("[#{opponent.pbThis} consumed its #{PBItems.getName(opponent.item)}]")
      finaldamagemult=(finaldamagemult*0.5).round
      opponent.pokemon.itemRecycle=opponent.item
      opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
      opponent.item=0
    end
    finaldamagemult=pbModifyDamage(finaldamagemult,attacker,opponent)
    damage=(damage*finaldamagemult*1.0/0x1000).round
    opponent.damagestate.calcdamage=damage
    PBDebug.log("   Move's damage calculated to be #{damage}")
    return damage
  end

  def pbReduceHPDamage(damage,attacker,opponent)
    endure=false
    if opponent.effects[PBEffects::Substitute]>0 && (!attacker || attacker.index!=opponent.index)
      PBDebug.log("[#{opponent.pbThis}'s substitute took the damage]")
      damage=opponent.effects[PBEffects::Substitute] if damage>opponent.effects[PBEffects::Substitute]
      opponent.effects[PBEffects::Substitute]-=damage
      opponent.damagestate.substitute=true
      @battle.scene.pbDamageAnimation(opponent,0)
      @battle.pbDisplayPaused(_INTL("The substitute took damage for {1}!",opponent.name))
      if opponent.effects[PBEffects::Substitute]<=0
        opponent.effects[PBEffects::Substitute]=0
        @battle.pbDisplayPaused(_INTL("{1}'s substitute faded!",opponent.name))
        PBDebug.log("[#{opponent.pbThis}'s substitute faded]")
      end
      opponent.damagestate.hplost=damage
      damage=0
    else
      opponent.damagestate.substitute=false
      if damage>=opponent.hp
        damage=opponent.hp
        if @function==0xE9 # False Swipe
          damage=damage-1
        elsif opponent.effects[PBEffects::Endure]
          damage=damage-1
          opponent.damagestate.endured=true
          PBDebug.log("[#{opponent.pbThis}'s Endure triggered]")
        elsif opponent.hasWorkingAbility(:STURDY) && damage==opponent.totalhp
          opponent.damagestate.sturdy=true
          damage=damage-1
          PBDebug.log("[#{opponent.pbThis}'s Sturdy triggered]")
        elsif opponent.damagestate.focussash && damage==opponent.totalhp
          opponent.damagestate.focussashused=true
          damage=damage-1
          opponent.pokemon.itemRecycle=opponent.item
          opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==opponent.item
          opponent.item=0
          PBDebug.log("[#{opponent.pbThis}'s Focus Sash triggered and was consumed]")
        elsif opponent.damagestate.focusband
          opponent.damagestate.focusbandused=true
          damage=damage-1
          PBDebug.log("[#{opponent.pbThis}'s Focus Band triggered]")
        end
        damage=0 if damage<0
      end
      oldhp=opponent.hp
      opponent.hp-=damage
      effectiveness=0
      if opponent.damagestate.typemod<4
        effectiveness=1   # "Not very effective"
      elsif opponent.damagestate.typemod>4
        effectiveness=2   # "Super effective"
      end
      if opponent.damagestate.typemod!=0
        @battle.scene.pbDamageAnimation(opponent,effectiveness)
      end
      @battle.scene.pbHPChanged(opponent,oldhp)
      opponent.damagestate.hplost=damage
    end
    return damage
  end

################################################################################
# Effects
################################################################################
  def pbEffectMessages(attacker,opponent,ignoretype=false)
    if opponent.damagestate.critical
      @battle.pbDisplay(_INTL("A critical hit!"))
    end
    if !pbIsMultiHit
      if opponent.damagestate.typemod>4
        @battle.pbDisplay(_INTL("It's super effective!"))
      elsif opponent.damagestate.typemod>=1 && opponent.damagestate.typemod<4
        @battle.pbDisplay(_INTL("It's not very effective..."))
      end
    end
    if opponent.damagestate.endured
      @battle.pbDisplay(_INTL("{1} endured the hit!",opponent.pbThis))
    elsif opponent.damagestate.sturdy
      @battle.pbDisplay(_INTL("{1} hung on with Sturdy!",opponent.pbThis))
    elsif opponent.damagestate.focussashused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Sash!",opponent.pbThis))
    elsif opponent.damagestate.focusbandused
      @battle.pbDisplay(_INTL("{1} hung on using its Focus Band!",opponent.pbThis))
    end
  end

  def pbEffectFixedDamage(damage,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    type=@type
    type=pbType(type,attacker,opponent)
    typemod=pbTypeModMessages(type,attacker,opponent)
    opponent.damagestate.critical=false
    opponent.damagestate.typemod=0
    opponent.damagestate.calcdamage=0
    opponent.damagestate.hplost=0
    if typemod!=0
      opponent.damagestate.calcdamage=damage
      opponent.damagestate.typemod=4
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      damage=1 if damage<1 # HP reduced can't be less than 1
      damage=pbReduceHPDamage(damage,attacker,opponent)
      pbEffectMessages(attacker,opponent)
      pbOnDamageLost(damage,attacker,opponent)
      return damage
    end
    return 0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return 0 if !opponent
    damage=pbCalcDamage(attacker,opponent)
    if opponent.damagestate.typemod!=0
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    end
    damage=pbReduceHPDamage(damage,attacker,opponent)
    pbEffectMessages(attacker,opponent)
    pbOnDamageLost(damage,attacker,opponent)
    return damage   # The HP lost by the opponent due to this attack
  end

################################################################################
# Using the move
################################################################################
  def pbOnStartUse(attacker)
    return true
  end

  def pbAddTarget(targets,attacker)
  end

  def pbSuccessCheck(attacker,opponent,numtargets)
  end

  def pbDisplayUseMessage(attacker)
  # Return values:
  # -1 if the attack should exit as a failure
  # 1 if the attack should exit as a success
  # 0 if the attack should proceed its effect
  # 2 if Bide is storing energy
    @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
    return 0
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return if !showanimation
    @battle.pbAnimation(id,attacker,opponent,hitnum)
  end

  def pbOnDamageLost(damage,attacker,opponent)
    #Used by Counter/Mirror Coat/Revenge/Focus Punch/Bide
    type=@type
    type=pbType(type,attacker,opponent)
    if opponent.effects[PBEffects::Bide]>0
      opponent.effects[PBEffects::BideDamage]+=damage
      opponent.effects[PBEffects::BideTarget]=attacker.index
    end
    if @function==0x90 # Hidden Power
      type=getConst(PBTypes,:NORMAL) || 0
    end
    if pbIsPhysical?(type)
      opponent.effects[PBEffects::Counter]=damage
      opponent.effects[PBEffects::CounterTarget]=attacker.index
    end
    if pbIsSpecial?(type)
      opponent.effects[PBEffects::MirrorCoat]=damage
      opponent.effects[PBEffects::MirrorCoatTarget]=attacker.index
    end
    opponent.lastHPLost=damage # for Revenge/Focus Punch/Metal Burst
    opponent.lastAttacker=attacker.index # for Revenge/Metal Burst
  end

  def pbMoveFailed(attacker,opponent)
    # Called to determine whether the move failed
    return false
  end
end