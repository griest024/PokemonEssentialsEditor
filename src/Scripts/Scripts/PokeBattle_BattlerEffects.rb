class PokeBattle_Battler
#===============================================================================
# Sleep
#===============================================================================
  def pbCanSleep?(showMessages,selfsleep=false,ignorestatus=false)
    return false if isFainted?
    if !ignorestatus && status==PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("{1} is already asleep!",pbThis)) if showMessages
      return false
    end
    if !selfsleep && (status!=0 || effects[PBEffects::Substitute]>0)
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        if @battle.battlers[i].effects[PBEffects::Uproar]>0
          @battle.pbDisplay(_INTL("But the uproar kept {1} awake!",pbThis(true))) if showMessages
          return false
        end
      end 
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      abilityname=PBAbilities.getName(self.ability)
      @battle.pbDisplay(_INTL("{1} stayed awake using its {2}!",pbThis,abilityname)) if showMessages
      return false
    end
    if !selfsleep && pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanSleepYawn?
    return false if status!=0
    if !hasWorkingAbility(:SOUNDPROOF)
      for i in 0...4
        return false if @battle.battlers[i].effects[PBEffects::Uproar]>0
      end
    end
    if hasWorkingAbility(:VITALSPIRIT) ||
       hasWorkingAbility(:INSOMNIA) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      return false
    end
    return true
  end

  def pbSleep
    self.status=PBStatuses::SLEEP
    self.statusCount=2+@battle.pbRandom(3)
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[#{pbThis}: fell asleep (#{self.statusCount} turns)]")
  end

  def pbSleepSelf(duration=-1)
    self.status=PBStatuses::SLEEP
    if duration>0
      self.statusCount=duration
    else
      self.statusCount=2+@battle.pbRandom(3)
    end
    pbCancelMoves
    @battle.pbCommonAnimation("Sleep",self,nil)
    PBDebug.log("[#{pbThis}: made itself fall asleep (#{self.statusCount} turns)]")
  end

#===============================================================================
# Poison
#===============================================================================
  def pbCanPoison?(showMessages)
    return false if isFainted?
    if status==PBStatuses::POISON
      @battle.pbDisplay(_INTL("{1} is already poisoned.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end   
    if hasWorkingAbility(:IMMUNITY) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents poisoning!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanPoisonSynchronize?(opponent)
    return false if isFainted?
    if (pbHasType?(:POISON) || pbHasType?(:STEEL)) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
         opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
      return false
    end   
    return false if self.status!=0
    if hasWorkingAbility(:IMMUNITY) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbCanPoisonSpikes?
    return false if isFainted?
    return false if self.status!=0
    return false if pbHasType?(:POISON) || pbHasType?(:STEEL)
    return false if hasWorkingAbility(:IMMUNITY)
    return false if hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY
    return false if pbOwnSide.effects[PBEffects::Safeguard]>0
    return true
  end

  def pbPoison(attacker,toxic=false)
    self.status=PBStatuses::POISON
    if toxic
      self.statusCount=1
      self.effects[PBEffects::Toxic]=0
    else
      self.statusCount=0
    end
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::POISON
    end
    @battle.pbCommonAnimation("Poison",self,nil)
    if toxic
      PBDebug.log("[#{pbThis}: was badly poisoned]")
    else
      PBDebug.log("[#{pbThis}: was poisoned")
    end
  end

#===============================================================================
# Burn
#===============================================================================
  def pbCanBurn?(showMessages)
    return false if isFainted?
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
       return false
    end
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnFromFireMove?(move,showMessages) # Use for status moves only
    return false if isFainted?
    if self.status==PBStatuses::BURN
      @battle.pbDisplay(_INTL("{1} already has a burn.",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",pbThis(true))) if showMessages
      return false
    end
    if hasWorkingAbility(:FLASHFIRE) && isConst?(move.type,PBTypes,:FIRE)
      if !@effects[PBEffects::FlashFire]
        @effects[PBEffects::FlashFire]=true
        @battle.pbDisplay(_INTL("{1}'s {2} raised its Fire power!",pbThis,PBAbilities.getName(self.ability)))
      else
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",pbThis,PBAbilities.getName(self.ability),move.name))
      end
      return false
    end
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents burns!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanBurnSynchronize?(opponent)
    return false if isFainted?
    return false if self.status!=0
    if pbHasType?(:FIRE) && !hasWorkingItem(:RINGTARGET)
       @battle.pbDisplay(_INTL("{1}'s {2} had no effect on {3}!",
          opponent.pbThis,PBAbilities.getName(opponent.ability),pbThis(true)))
       return false
    end   
    if hasWorkingAbility(:WATERVEIL) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbBurn(attacker)
    self.status=PBStatuses::BURN
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::BURN
    end
    @battle.pbCommonAnimation("Burn",self,nil)
    PBDebug.log("[#{pbThis}: was burned")
  end

#===============================================================================
# Paralyze
#===============================================================================
  def pbCanParalyze?(showMessages)
    return false if isFainted?
    if status==PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("{1} is already paralyzed!",pbThis)) if showMessages
      return false
    end
    if self.status!=0 || @effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents paralysis!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanParalyzeSynchronize?(opponent)
    return false if self.status!=0
    if hasWorkingAbility(:LIMBER) ||
       (hasWorkingAbility(:LEAFGUARD) && @battle.pbWeather==PBWeather::SUNNYDAY)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3}'s {4} from working!",
         pbThis,PBAbilities.getName(self.ability),
         opponent.pbThis(true),PBAbilities.getName(opponent.ability)))
      return false
    end
    return true
  end

  def pbParalyze(attacker)
    self.status=PBStatuses::PARALYSIS
    self.statusCount=0
    if self.index!=attacker.index
      @battle.synchronize[0]=self.index
      @battle.synchronize[1]=attacker.index
      @battle.synchronize[2]=PBStatuses::PARALYSIS
    end
    @battle.pbCommonAnimation("Paralysis",self,nil)
    PBDebug.log("[#{pbThis}: was paralyzed")
  end

#===============================================================================
# Freeze
#===============================================================================
  def pbCanFreeze?(showMessages)
    return false if isFainted?
    if @battle.pbWeather==PBWeather::SUNNYDAY || self.status!=0 ||
       hasWorkingAbility(:MAGMAARMOR) ||
       pbOwnSide.effects[PBEffects::Safeguard]>0 ||
       effects[PBEffects::Substitute]>0 ||
       (pbHasType?(:ICE) && !hasWorkingItem(:RINGTARGET))
      return false
    end
    return true
  end

  def pbFreeze
    self.status=PBStatuses::FROZEN
    self.statusCount=0
    pbCancelMoves
    @battle.pbCommonAnimation("Frozen",self,nil)
    PBDebug.log("[#{pbThis}: was frozen")
  end

#===============================================================================
# Generalised status displays
#===============================================================================
  def pbContinueStatus(showAnim=true)
    case self.status
    when PBStatuses::SLEEP
      @battle.pbCommonAnimation("Sleep",self,nil)
      @battle.pbDisplay(_INTL("{1} is fast asleep.",pbThis))
    when PBStatuses::POISON
      @battle.pbCommonAnimation("Poison",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by poison!",pbThis))
    when PBStatuses::BURN
      @battle.pbCommonAnimation("Burn",self,nil)
      @battle.pbDisplay(_INTL("{1} is hurt by its burn!",pbThis))
    when PBStatuses::PARALYSIS
      @battle.pbCommonAnimation("Paralysis",self,nil)
      @battle.pbDisplay(_INTL("{1} is paralyzed!  It can't move!",pbThis)) 
    when PBStatuses::FROZEN
      @battle.pbCommonAnimation("Frozen",self,nil)
      @battle.pbDisplay(_INTL("{1} is frozen solid!",pbThis))
    end
  end

  def pbCureStatus(showMessages=true)
    oldstatus=self.status
    if self.status==PBStatuses::SLEEP
      self.effects[PBEffects::Nightmare]=false
    end
    self.status=0
    self.statusCount=0
    if showMessages
      case oldstatus
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} woke up!",pbThis))
      when PBStatuses::POISON
      when PBStatuses::BURN
      when PBStatuses::PARALYSIS
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} was defrosted!",pbThis))
      end
    end
    PBDebug.log("[#{pbThis}: status problem was cured]")
  end

#===============================================================================
# Confuse
#===============================================================================
  def pbCanConfuse?(showMessages)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    if pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("{1}'s team is protected by Safeguard!",pbThis)) if showMessages
      return false
    end
    return true
  end

  def pbCanConfuseSelf?(showMessages)
    return false if isFainted?
    if effects[PBEffects::Confusion]>0
      @battle.pbDisplay(_INTL("{1} is already confused!",pbThis)) if showMessages
      return false
    end
    if hasWorkingAbility(:OWNTEMPO)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents confusion!",pbThis,PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbConfuseSelf
    if @effects[PBEffects::Confusion]==0 && !hasWorkingAbility(:OWNTEMPO)
      @effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",self,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",pbThis))
      PBDebug.log("[#{pbThis}: became confused (#{self.statusCount} turns)]")
    end
  end

  def pbContinueConfusion
    @battle.pbCommonAnimation("Confusion",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is confused!",pbThis))
  end

  def pbCureConfusion(showMessages=true)
    @effects[PBEffects::Confusion]=0
    @battle.pbDisplay(_INTL("{1} snapped out of confusion!",pbThis)) if showMessages
    PBDebug.log("[#{pbThis}: cured its confusion]")
  end

#===============================================================================
# Attraction
#===============================================================================
  def pbCanAttract?(attacker,showMessages=true)
    return false if isFainted?
    return false if !attacker
    if @effects[PBEffects::Attract]>=0
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    agender=attacker.gender
    ogender=self.gender
    if agender==2 || ogender==2 || agender==ogender
      @battle.pbDisplay(_INTL("But it failed!")) if showMessages
      return false
    end
    if hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",pbThis,
         PBAbilities.getName(self.ability))) if showMessages
      return false
    end
    return true
  end

  def pbAnnounceAttract(seducer)
    @battle.pbCommonAnimation("Attract",self,nil)
    @battle.pbDisplayBrief(_INTL("{1} is in love with {2}!",
       pbThis,seducer.pbThis(true)))
  end

  def pbContinueAttract
    @battle.pbDisplay(_INTL("{1} is immobilized by love!",pbThis)) 
  end

#===============================================================================
# Increase stat stages
#===============================================================================
  def pbTooHigh?(stat)
    return @stages[stat]>=6
  end

  def pbCanIncreaseStatStage?(stat,showMessages=false)
    return false if isFainted?
    if pbTooHigh?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go any higher!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go any higher!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go any higher!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go any higher!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go any higher!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go any higher!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go any higher!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbIncreaseStatBasic(stat,increment)
    increment*=2 if hasWorkingAbility(:SIMPLE)
    PBDebug.log("[#{pbThis}: stat #{getConstantName(PBStats,stat)} rose by #{increment} stage(s) (was #{@stages[stat]}, now #{[@stages[stat]+increment,6].min}]")
    @stages[stat]+=increment
    @stages[stat]=6 if @stages[stat]>6
  end

  def pbIncreaseStat(stat,increment,showMessages,upanim=true)
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack rose!",pbThis),
         _INTL("{1}'s Attack rose sharply!",pbThis),
         _INTL("{1}'s Attack rose drastically!",pbThis),
         _INTL("{1}'s Attack went way up!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense rose!",pbThis),
         _INTL("{1}'s Defense rose sharply!",pbThis),
         _INTL("{1}'s Defense rose drastically!",pbThis),
         _INTL("{1}'s Defense went way up!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed rose!",pbThis),
         _INTL("{1}'s Speed rose sharply!",pbThis),
         _INTL("{1}'s Speed rose drastically!",pbThis),
         _INTL("{1}'s Speed went way up!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack rose!",pbThis),
         _INTL("{1}'s Special Attack rose sharply!",pbThis),
         _INTL("{1}'s Special Attack rose drastically!",pbThis),
         _INTL("{1}'s Special Attack went way up!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense rose!",pbThis),
         _INTL("{1}'s Special Defense rose sharply!",pbThis),
         _INTL("{1}'s Special Defense rose drastically!",pbThis),
         _INTL("{1}'s Special Defense went way up!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness rose!",pbThis),
         _INTL("{1}'s evasiveness rose sharply!",pbThis),
         _INTL("{1}'s evasiveness rose drastically!",pbThis),
         _INTL("{1}'s evasiveness went way up!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy rose!",pbThis),
         _INTL("{1}'s accuracy rose sharply!",pbThis),
         _INTL("{1}'s accuracy rose drastically!",pbThis),
         _INTL("{1}'s accuracy went way up!",pbThis)]
    else
      return false
    end
    if pbCanIncreaseStatStage?(stat,showMessages)
      pbIncreaseStatBasic(stat,increment)
      @battle.pbCommonAnimation("StatUp",self,nil) if upanim
      if increment>3
        @battle.pbDisplay(arrStatTexts[3])
      elsif increment==3
        @battle.pbDisplay(arrStatTexts[2])
      elsif increment==2
        @battle.pbDisplay(arrStatTexts[1])
      else
        @battle.pbDisplay(arrStatTexts[0])
      end
      return true
    end
    return false
  end

#===============================================================================
# Decrease stat stages
#===============================================================================
  def pbTooLow?(stat)
    return @stages[stat]<=-6
  end

  # Tickle (04A) and Memento (0E2) can't use this, but replicate it instead.
  # (Reason is they lower more than 1 stat independently, and therefore could
  # show certain messages twice which is undesirable.)
  def pbCanReduceStatStage?(stat,showMessages=false,selfreduce=false)
    return false if isFainted?
    if !selfreduce
      if effects[PBEffects::Substitute]>0
        @battle.pbDisplay(_INTL("But it failed!")) if showMessages
        return false
      end
      if pbOwnSide.effects[PBEffects::Mist]>0
        @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis)) if showMessages
        return false
      end
      if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::ATTACK && hasWorkingAbility(:HYPERCUTTER)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Attack loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::DEFENSE && hasWorkingAbility(:BIGPECKS)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Defense loss!",pbThis,abilityname)) if showMessages
        return false
      end
      if stat==PBStats::ACCURACY && hasWorkingAbility(:KEENEYE)
        abilityname=PBAbilities.getName(self.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} prevents Accuracy loss!",pbThis,abilityname)) if showMessages
        return false
      end
    end
    if pbTooLow?(stat)
      if showMessages
        @battle.pbDisplay(_INTL("{1}'s Attack won't go any lower!",pbThis)) if stat==PBStats::ATTACK
        @battle.pbDisplay(_INTL("{1}'s Defense won't go any lower!",pbThis)) if stat==PBStats::DEFENSE
        @battle.pbDisplay(_INTL("{1}'s Speed won't go any lower!",pbThis)) if stat==PBStats::SPEED
        @battle.pbDisplay(_INTL("{1}'s Special Attack won't go any lower!",pbThis)) if stat==PBStats::SPATK
        @battle.pbDisplay(_INTL("{1}'s Special Defense won't go any lower!",pbThis)) if stat==PBStats::SPDEF
        @battle.pbDisplay(_INTL("{1}'s evasiveness won't go any lower!",pbThis)) if stat==PBStats::EVASION
        @battle.pbDisplay(_INTL("{1}'s accuracy won't go any lower!",pbThis)) if stat==PBStats::ACCURACY
      end
      return false
    end
    return true
  end

  def pbReduceStatBasic(stat,increment)
    increment*=2 if hasWorkingAbility(:SIMPLE)
    PBDebug.log("[#{pbThis}: stat #{getConstantName(PBStats,stat)} fell by #{increment} stage(s) (was #{@stages[stat]}, now #{[@stages[stat]-increment,-6].max}]")
    @stages[stat]-=increment
    @stages[stat]=-6 if @stages[stat]<-6
  end

  def pbReduceStat(stat,increment,showMessages,downanim=true,selfreduce=false)
    arrStatTexts=[]
    if stat==PBStats::ATTACK
      arrStatTexts=[_INTL("{1}'s Attack fell!",pbThis),
         _INTL("{1}'s Attack harshly fell!",pbThis)]
    elsif stat==PBStats::DEFENSE
      arrStatTexts=[_INTL("{1}'s Defense fell!",pbThis),
         _INTL("{1}'s Defense harshly fell!",pbThis)]
    elsif stat==PBStats::SPEED
      arrStatTexts=[_INTL("{1}'s Speed fell!",pbThis),
         _INTL("{1}'s Speed harshly fell!",pbThis)]
    elsif stat==PBStats::SPATK
      arrStatTexts=[_INTL("{1}'s Special Attack fell!",pbThis),
         _INTL("{1}'s Special Attack harshly fell!",pbThis)]
    elsif stat==PBStats::SPDEF
      arrStatTexts=[_INTL("{1}'s Special Defense fell!",pbThis),
         _INTL("{1}'s Special Defense harshly fell!",pbThis)]
    elsif stat==PBStats::EVASION
      arrStatTexts=[_INTL("{1}'s evasiveness fell!",pbThis),
         _INTL("{1}'s evasiveness harshly fell!",pbThis)]
    elsif stat==PBStats::ACCURACY
      arrStatTexts=[_INTL("{1}'s accuracy fell!",pbThis),
         _INTL("{1}'s accuracy harshly fell!",pbThis)]
    else
      return false
    end
    if pbCanReduceStatStage?(stat,showMessages,selfreduce)
      pbReduceStatBasic(stat,increment)
      @battle.pbCommonAnimation("StatDown",self,nil) if downanim
      if increment>=2
        @battle.pbDisplay(arrStatTexts[1])
      else
        @battle.pbDisplay(arrStatTexts[0])
      end
      return true
    end
    return false
  end

  def pbReduceAttackStatStageIntimidate(opponent)
    return false if isFainted?
    return false if effects[PBEffects::Substitute]>0
    if hasWorkingAbility(:CLEARBODY) || hasWorkingAbility(:WHITESMOKE) ||
       hasWorkingAbility(:HYPERCUTTER)
      abilityname=PBAbilities.getName(self.ability)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} prevented {3}'s {4} from working!",
         pbThis,abilityname,opponent.pbThis(true),oppabilityname))
      return false
    end
    if pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",pbThis))
      return false
    end
    if pbCanReduceStatStage?(PBStats::ATTACK,false)
      pbReduceStatBasic(PBStats::ATTACK,1)
      oppabilityname=PBAbilities.getName(opponent.ability)
      @battle.pbCommonAnimation("StatDown",self,nil)
      @battle.pbDisplay(_INTL("{1}'s {2} cuts {3}'s Attack!",opponent.pbThis,
         oppabilityname,pbThis(true)))
      return true
    end
    return false
  end
end