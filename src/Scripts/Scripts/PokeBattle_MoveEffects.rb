################################################################################
# Superclass that handles moves using a non-existent function code.
# Damaging moves just do damage with no additional effect.
# Non-damaging moves always fail.
################################################################################
class PokeBattle_UnimplementedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @basedamage>0
      return super(attacker,opponent,hitnum,alltargets,showanimation)
    else
      @battle.pbDisplay("But it failed!")
      return -1
    end
  end
end



################################################################################
# Superclass for a failed move.  Always fails.
################################################################################
class PokeBattle_FailedMove < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @battle.pbDisplay("But it failed!")
    return -1
  end
end



################################################################################
# Pseudomove for confusion damage
################################################################################
class PokeBattle_Confusion < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @basedamage = 40
    @type       = -1
    @accuracy   = 100
    @pp         = -1
    @addlEffect = 0
    @target     = 0
    @priority   = 0
    @flags      = 0
    @thismove   = move
    @name       = ""
    @id         = 0
  end

  def pbIsPhysical?(type)
    return true
  end

  def pbIsSpecial?(type)
    return false
  end

  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,
       PokeBattle_Move::NOCRITICAL|PokeBattle_Move::SELFCONFUSE|PokeBattle_Move::NOTYPE|PokeBattle_Move::NOWEIGHTING)
  end

  def pbEffectMessages(attacker,opponent,ignoretype=false)
    return super(attacker,opponent,true)
  end
end



################################################################################
# Implements the move Struggle.
# For cases where the real move named Struggle is not defined.
################################################################################
class PokeBattle_Struggle < PokeBattle_Move
  def initialize(battle,move)
    @battle     = battle
    @basedamage = 50
    @type       = -1
    @accuracy   = 100
    @pp         = -1
    @totalpp    = 0
    @addlEffect = 0
    @target     = 0
    @priority   = 0
    @flags      = 0
    @thismove   = nil   # not associated with a move
    @name       = ""
    @id         = -1    # doesn't work if 0
  end

  def pbIsPhysical?(type)
    return true
  end

  def pbIsSpecial?(type)
    return false
  end

  def pbDisplayUseMessage(attacker)
    @battle.pbDisplayBrief(_INTL("{1} is struggling!",attacker.pbThis))
    return 0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.pbReduceHP((attacker.totalhp/4).floor)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,PokeBattle_Move::IGNOREPKMNTYPES)
  end
end



################################################################################
# No additional effect.
################################################################################
class PokeBattle_Move_000 < PokeBattle_Move
end



################################################################################
# Does absolutely nothing (Splash).
################################################################################
class PokeBattle_Move_001 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("But nothing happened!"))
    return 0
  end
end



################################################################################
# Struggle.  Overrides the default Struggle effect above.
################################################################################
class PokeBattle_Move_002 < PokeBattle_Struggle
end



################################################################################
# Puts the target to sleep.
################################################################################
class PokeBattle_Move_003 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbCanSleep?(true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanSleep?(false)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Makes the target drowsy.  It will fall asleep at the end of the next turn.
################################################################################
class PokeBattle_Move_004 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !opponent.pbCanSleep?(true)
    if opponent.effects[PBEffects::Yawn]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Yawn]=2
    @battle.pbDisplay(_INTL("{1} made {2} drowsy!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Poisons the target.
################################################################################
class PokeBattle_Move_005 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanPoison?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Badly poisons the target.
################################################################################
class PokeBattle_Move_006 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanPoison?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker,true)
    @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.
################################################################################
class PokeBattle_Move_007 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanParalyze?(true)
    if isConst?(@id,PBMoves,:THUNDERWAVE)
      typemod=pbTypeModifier(@type,attacker,opponent)
      if typemod==0
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.  (Thunder)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
# (Handled in pbAccuracyCheck): Accuracy perfect in rain, 50% in sunshine.
################################################################################
class PokeBattle_Move_008 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Paralyzes the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_009 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    hadeffect=false
    if @battle.pbRandom(10)==0
      break if !opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
      hadeffect=true
    end
    if @battle.pbRandom(10)==0
      if !opponent.hasWorkingAbility(:INNERFOCUS) &&
         opponent.effects[PBEffects::Substitute]==0
        opponent.effects[PBEffects::Flinch]=true
        hadeffect=true
      end
    end
    return hadeffect
  end
end



################################################################################
# Burns the target.
################################################################################
class PokeBattle_Move_00A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum) if @basedamage>0
    return -1 if !opponent.pbCanBurnFromFireMove?(self,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Burns the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_00B < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    hadeffect=false
    if @battle.pbRandom(10)==0
      break if !opponent.pbCanBurn?(false)
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      hadeffect=true
    end
    if @battle.pbRandom(10)==0
      if !opponent.hasWorkingAbility(:INNERFOCUS) &&
         opponent.effects[PBEffects::Substitute]==0
        opponent.effects[PBEffects::Flinch]=true
        hadeffect=true
      end
    end
    return hadeffect
  end
end



################################################################################
# Freezes the target.
################################################################################
class PokeBattle_Move_00C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Freezes the target.
# (Handled in pbAccuracyCheck): Accuracy perfect in hail.
################################################################################
class PokeBattle_Move_00D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanFreeze?(true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.pbFreeze
    @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Freezes the target.  May cause the target to flinch.
################################################################################
class PokeBattle_Move_00E < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    hadeffect=false
    if @battle.pbRandom(10)==0
      break if !opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      hadeffect=true
    end
    if @battle.pbRandom(10)==0
      if !opponent.hasWorkingAbility(:INNERFOCUS) &&
         opponent.effects[PBEffects::Substitute]==0
        opponent.effects[PBEffects::Flinch]=true
        hadeffect=true
      end
    end
    return hadeffect
  end
end



################################################################################
# Causes the target to flinch.
################################################################################
class PokeBattle_Move_00F < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end



################################################################################
# Causes the target to flinch.  Does double damage if the target is Minimized.
################################################################################
class PokeBattle_Move_010 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if opponent.effects[PBEffects::Minimize]
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Causes the target to flinch.  Fails if the user is not asleep.
################################################################################
class PokeBattle_Move_011 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.status!=PBStatuses::SLEEP)
  end
end



################################################################################
# Causes the target to flinch.  Fails if this isn't the user's first turn.
################################################################################
class PokeBattle_Move_012 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end

  def pbMoveFailed(attacker,opponent)
    return (attacker.turncount!=1)
  end
end



################################################################################
# Confuses the target.
################################################################################
class PokeBattle_Move_013 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbCanConfuse?(true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Confuses the target.  Chance of causing confusion depends on the cry's volume.
# Confusion chance is 0% if user is not Chatot.  (Chatter)
################################################################################
class PokeBattle_Move_014 < PokeBattle_Move
  #TODO: Play the actual chatter cry as part of the move animation
# @battle.scene.pbChatter(attacker,opponent) # Just plays cry
  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      if isConst?(attacker.species,PBSpecies,:CHATOT) &&
         !attacker.effects[PBEffects::Transform] &&
         !opponent.hasWorkingAbility(:SHIELDDUST)
        chance=0
        if attacker.pokemon && attacker.pokemon.chatter
          chance+=attacker.pokemon.chatter.intensity*10/127
        end
        if rand(100)<chance
          opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
          @battle.pbCommonAnimation("Confusion",opponent,nil)
          @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
          return true
        end
      end
    end
    return false
  end
end



################################################################################
# Confuses the target.  (Hurricane)
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
# (Handled in pbAccuracyCheck): Accuracy perfect in rain, 50% in sunshine.
################################################################################
class PokeBattle_Move_015 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if opponent.pbCanConfuse?(true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return 0
    end
    return -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanConfuse?(false)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      return true
    end
    return false
  end
end



################################################################################
# Attracts the target.
################################################################################
class PokeBattle_Move_016 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbCanAttract?(attacker)
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Attract]=attacker.index
    @battle.pbCommonAnimation("Attract",opponent,nil)
    @battle.pbDisplay(_INTL("{1} fell in love!",opponent.pbThis))
    if opponent.hasWorkingItem(:DESTINYKNOT) &&
       !attacker.hasWorkingAbility(:OBLIVIOUS) &&
       attacker.effects[PBEffects::Attract]<0
      attacker.effects[PBEffects::Attract]=user.index
      @battle.pbCommonAnimation("Attract",attacker,nil)
      pbDisplay(_INTL("{1}'s {2} infatuated {3}!",opponent.pbThis,
         PBItems.getName(opponent.item),attacker.pbThis(true)))
    end
    return 0
  end
end



################################################################################
# Burns, freezes or paralyzes the target.
################################################################################
class PokeBattle_Move_017 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    rnd=@battle.pbRandom(3)
    case rnd
    when 0
      return false if !opponent.pbCanBurn?(false)
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    when 1
      return false if !opponent.pbCanFreeze?(false)
      opponent.pbFreeze
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
    when 2
      return false if !opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    end
    return true
  end
end



################################################################################
# Cures user of burn, poison and paralysis.
################################################################################
class PokeBattle_Move_018 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::BURN &&
       attacker.status!=PBStatuses::POISON &&
       attacker.status!=PBStatuses::PARALYSIS
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    else
      t=attacker.status
      attacker.status=0
      attacker.statusCount=0
      pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
      if t==PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))  
      elsif t==PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))  
      elsif t==PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))  
      end
      return 0
    end
  end
end



################################################################################
# Cures all party Pokémon of permanent status problems.
################################################################################
class PokeBattle_Move_019 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if isConst?(@id,PBMoves,:AROMATHERAPY)
      @battle.pbDisplay(_INTL("A soothing aroma wafted through the area!"))
    else
      @battle.pbDisplay(_INTL("A bell chimed!"))
    end
    activepkmn=[]
    for i in @battle.battlers
      next if attacker.pbIsOpposing?(i.index)
      case i.status
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",i.pbThis))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from its sleep.",i.pbThis))
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",i.pbThis))
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",i.pbThis))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} was defrosted.",i.pbThis))
      end
      i.status=0
      i.statusCount=0
      activepkmn.push(i.pokemonIndex)
    end
    party=@battle.pbParty(attacker.index) # NOTE: Considers both parties in multi battles
    for i in 0...party.length
      next if activepkmn.include?(i)
      next if !party[i] || party[i].isEgg?
      case party[i].status
      when PBStatuses::PARALYSIS
        @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",party[i].name))
      when PBStatuses::SLEEP
        @battle.pbDisplay(_INTL("{1} was woken from its sleep.",party[i].name))
      when PBStatuses::POISON
        @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",party[i].name))
      when PBStatuses::BURN
        @battle.pbDisplay(_INTL("{1} was cured of its burn.",party[i].name))
      when PBStatuses::FROZEN
        @battle.pbDisplay(_INTL("{1} was defrosted.",party[i].name))
      end
      party[i].status=0
      party[i].statusCount=0
    end
    return 0
  end
end



################################################################################
# Safeguards the user's side from being inflicted with status problems.
################################################################################
class PokeBattle_Move_01A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Safeguard]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    attacker.pbOwnSide.effects[PBEffects::Safeguard]=5
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became cloaked in a mystical veil!"))
    else
      @battle.pbDisplay(_INTL("The foe's team became cloaked in a mystical veil!"))
    end
    return 0
  end
end



################################################################################
# User passes its status problem to the target.
################################################################################
class PokeBattle_Move_01B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status==0 ||
      (attacker.status==PBStatuses::PARALYSIS && !opponent.pbCanParalyze?(false)) ||
      (attacker.status==PBStatuses::SLEEP && !opponent.pbCanSleep?(false)) ||
      (attacker.status==PBStatuses::POISON && !opponent.pbCanPoison?(false)) ||
      (attacker.status==PBStatuses::BURN && !opponent.pbCanBurn?(false)) ||
      (attacker.status==PBStatuses::FROZEN && !opponent.pbCanFreeze?(false))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    case attacker.status
    when PBStatuses::PARALYSIS
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
      opponent.pbAbilityCureCheck
      @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::PARALYSIS
      attacker.status=0
      @battle.pbDisplay(_INTL("{1} was cured of its paralysis.",attacker.pbThis))
    when PBStatuses::SLEEP
      opponent.pbSleep(attacker)
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))
      opponent.pbAbilityCureCheck
      @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::SLEEP
      attacker.status=0
      attacker.statusCount=0
      @battle.pbDisplay(_INTL("{1} was woken from its sleep.",attacker.pbThis))
    when PBStatuses::POISON
      opponent.pbPoison(attacker,attacker.statusCount!=0)
      if attacker.statusCount!=0
        @battle.pbDisplay(_INTL("{1} is badly poisoned!",opponent.pbThis))
      else
        @battle.pbDisplay(_INTL("{1} is poisoned!",opponent.pbThis))
      end
      opponent.pbAbilityCureCheck
      @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::POISON
      attacker.status=0
      attacker.statusCount=0
      @battle.pbDisplay(_INTL("{1} was cured of its poisoning.",attacker.pbThis))
    when PBStatuses::BURN
      opponent.pbBurn(attacker)
      @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
      opponent.pbAbilityCureCheck
      @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::BURN
      attacker.status=0
      @battle.pbDisplay(_INTL("{1} was cured of its burn.",attacker.pbThis))
    when PBStatuses::FROZEN
      opponent.pbFreeze(attacker)
      @battle.pbDisplay(_INTL("{1} was frozen solid!",opponent.pbThis))
      opponent.pbAbilityCureCheck
      @battle.synchronize=[-1,-1,0] if opponent.status!=PBStatuses::FROZEN
      attacker.status=0
      @battle.pbDisplay(_INTL("{1} was defrosted.",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack by 1 stage.
################################################################################
class PokeBattle_Move_01C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::ATTACK,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 1 stage.
################################################################################
class PokeBattle_Move_01D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 1 stage.  User curls up.
################################################################################
class PokeBattle_Move_01E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,1,false)
    attacker.effects[PBEffects::DefenseCurl]=true if ret
    return ret ? 0 : -1
  end
end



################################################################################
# Increases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_01F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_020 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Special Defense by 1 stage.  Charges up Electric attacks.
################################################################################
class PokeBattle_Move_021 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::Charge]=2
    @battle.pbDisplay(_INTL("{1} began charging power!",attacker.pbThis))
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,true)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false)
    end
    return 0
  end
end



################################################################################
# Increases the user's evasion by 1 stage.
################################################################################
class PokeBattle_Move_022 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,1,false)
    end
    return true
  end
end



################################################################################
# Increases the user's critical hit rate.
################################################################################
class PokeBattle_Move_023 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    if attacker.effects[PBEffects::FocusEnergy]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::FocusEnergy]=2
    @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.effects[PBEffects::FocusEnergy]<2
      attacker.effects[PBEffects::FocusEnergy]=2
      @battle.pbDisplay(_INTL("{1} is getting pumped!",attacker.pbThis))
    end
    return true
  end
end



################################################################################
# Increases the user's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_024 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense and accuracy by 1 stage each.
################################################################################
class PokeBattle_Move_025 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      attacker.pbIncreaseStat(PBStats::ACCURACY,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Speed by 1 stage each.
################################################################################
class PokeBattle_Move_026 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Special Attack by 1 stage each.
################################################################################
class PokeBattle_Move_027 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and Sp. Attack by 1 stage each (2 each in sunshine).
################################################################################
class PokeBattle_Move_028 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    increment=(@battle.weather==PBWeather::SUNNYDAY) ? 2 : 1
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,increment,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,increment,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack and accuracy by 1 stage each.
################################################################################
class PokeBattle_Move_029 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::ACCURACY,false)
      attacker.pbIncreaseStat(PBStats::ACCURACY,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Defense and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_02A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Special Attack, Special Defense and Speed  by 1 stage each.
################################################################################
class PokeBattle_Move_02B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Special Attack and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_02C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Attack, Defense, Speed, Special Attack and Special Defense
# by 1 stage each.
################################################################################
class PokeBattle_Move_02D < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,1,false,showanim)
      showanim=false
    end
    return true
  end
end



################################################################################
# Increases the user's Attack by 2 stages.
################################################################################
class PokeBattle_Move_02E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::ATTACK,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Defense by 2 stages.
################################################################################
class PokeBattle_Move_02F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,2,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Speed by 2 stages.
################################################################################
class PokeBattle_Move_030 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Speed by 2 stages.  Halves the user's weight.
################################################################################
class PokeBattle_Move_031 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPEED,2,false)
    if ret
      attacker.effects[PBEffects::WeightMultiplier]/=2
      @battle.pbDisplay(_INTL("{1} became nimble!",attacker.pbThis))
    end
    return ret ? 0 : -1
  end
end



################################################################################
# Increases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_032 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_033 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPDEF,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,2,false)
    end
    return true
  end
end



################################################################################
# Increases the user's evasion by 2 stages.  Minimizes the user.
################################################################################
class PokeBattle_Move_034 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::EVASION,2,false)
    attacker.effects[PBEffects::Minimize]=true if ret
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::EVASION,false)
      attacker.pbIncreaseStat(PBStats::EVASION,2,false)
      attacker.effects[PBEffects::Minimize]=true
    end
    return true
  end
end



################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
# Increases the user's Attack, Speed and Special Attack by 2 stages each.
################################################################################
class PokeBattle_Move_035 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
      attacker.pbReduceStat(PBStats::DEFENSE,1,false,showanim,true)
      showanim=false
    end
    if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
      attacker.pbReduceStat(PBStats::SPDEF,1,false,showanim,true)
      showanim=false
    end
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,2,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPATK,false)
      attacker.pbIncreaseStat(PBStats::SPATK,2,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases the user's Speed by 2 stages, and its Attack by 1 stage.
################################################################################
class PokeBattle_Move_036 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false) &&
       !attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPEED,false)
      attacker.pbIncreaseStat(PBStats::SPEED,2,false,showanim)
      showanim=false
    end
    return 0
  end
end



################################################################################
# Increases one random stat of the user by 2 stages (except HP).
################################################################################
class PokeBattle_Move_037 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.index!=opponent.index && opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    array=[]
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      array.push(i) if opponent.pbCanIncreaseStatStage?(i)
    end
    if array.length==0
      @battle.pbDisplay(_INTL("{1}'s stats won't go any higher!",opponent.pbThis))
      return -1
    end
    stat=array[@battle.pbRandom(array.length)]
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbIncreaseStat(stat,2,false)
    return 0
  end
end



################################################################################
# Increases the user's Defense by 3 stages.
################################################################################
class PokeBattle_Move_038 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::DEFENSE,3,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,3,false)
    end
    return true
  end
end



################################################################################
# Increases the user's Special Attack by 3 stages.
################################################################################
class PokeBattle_Move_039 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !attacker.pbCanIncreaseStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=attacker.pbIncreaseStat(PBStats::SPATK,3,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::SPATK,3,false)
    end
    return true
  end
end



################################################################################
# Reduces the user's HP by half of max, and sets its Attack to maximum.
################################################################################
class PokeBattle_Move_03A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp<=(attacker.totalhp/2).floor ||
       !attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbReduceHP((attacker.totalhp/2).floor)
    attacker.stages[PBStats::ATTACK]=6
    @battle.pbCommonAnimation("StatUp",attacker,nil)
    @battle.pbDisplay(_INTL("{1} cut its own HP and maximized its Attack!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Decreases the user's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_03B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      showanim=true
      if attacker.pbCanReduceStatStage?(PBStats::ATTACK,false,true)
        attacker.pbReduceStat(PBStats::ATTACK,1,false,showanim,true)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,1,false,showanim,true)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense and Special Defense by 1 stage each.
################################################################################
class PokeBattle_Move_03C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      showanim=true
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,1,false,showanim,true)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,1,false,showanim,true)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Defense, Special Defense and Speed by 1 stage each.
# User's ally loses 1/16 of its total HP.
################################################################################
class PokeBattle_Move_03D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      showanim=true
      if attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
        attacker.pbReduceStat(PBStats::SPEED,1,false,showanim,true)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,1,false,showanim,true)
        showanim=false
      end
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,1,false,showanim,true)
        showanim=false
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Speed by 1 stage.
################################################################################
class PokeBattle_Move_03E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
        attacker.pbReduceStat(PBStats::SPEED,1,false,true,true)
      end
    end
    return ret
  end
end



################################################################################
# Decreases the user's Special Attack by 2 stages.
################################################################################
class PokeBattle_Move_03F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.pbCanReduceStatStage?(PBStats::SPATK,false,true)
        attacker.pbReduceStat(PBStats::SPATK,2,false,true,true)
      end
    end
    return ret
  end
end



################################################################################
# Increases the target's Special Attack by 1 stage.  Confuses the target.
################################################################################
class PokeBattle_Move_040 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::SPATK)
      opponent.pbIncreaseStat(PBStats::SPATK,1,false)
      ret=0
    end
    if opponent.pbCanConfuse?(true)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Increases the target's Attack by 2 stages.  Confuses the target.
################################################################################
class PokeBattle_Move_041 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    ret=-1
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.pbCanIncreaseStatStage?(PBStats::ATTACK)
      opponent.pbIncreaseStat(PBStats::ATTACK,2,false)
      ret=0
    end
    if opponent.pbCanConfuse?(true)
      opponent.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
      @battle.pbCommonAnimation("Confusion",opponent,nil)
      @battle.pbDisplay(_INTL("{1} became confused!",opponent.pbThis))
      ret=0
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack by 1 stage.
################################################################################
class PokeBattle_Move_042 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
      opponent.pbReduceStat(PBStats::ATTACK,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Defense by 1 stage.
################################################################################
class PokeBattle_Move_043 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Speed by 1 stage.
################################################################################
class PokeBattle_Move_044 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
      opponent.pbReduceStat(PBStats::SPEED,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Special Attack by 1 stage.
################################################################################
class PokeBattle_Move_045 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
      opponent.pbReduceStat(PBStats::SPATK,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Special Defense by 1 stage.
################################################################################
class PokeBattle_Move_046 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
      opponent.pbReduceStat(PBStats::SPDEF,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's accuracy by 1 stage.
################################################################################
class PokeBattle_Move_047 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ACCURACY,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::ACCURACY,false)
      opponent.pbReduceStat(PBStats::ACCURACY,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's evasion by 1 stage.
################################################################################
class PokeBattle_Move_048 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::EVASION,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::EVASION,1,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,false)
      opponent.pbReduceStat(PBStats::EVASION,1,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's evasion by 1 stage.  Ends all barriers and entry
# hazards for the target's side.
################################################################################
class PokeBattle_Move_049 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::EVASION,1,false)
    opponent.pbOwnSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOwnSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOwnSide.effects[PBEffects::Mist]        = 0
    opponent.pbOwnSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOwnSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOwnSide.effects[PBEffects::StealthRock] = false
    opponent.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
    return 0
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::EVASION,false)
      opponent.pbReduceStat(PBStats::EVASION,1,false)
    end
    opponent.pbOwnSide.effects[PBEffects::Reflect]     = 0
    opponent.pbOwnSide.effects[PBEffects::LightScreen] = 0
    opponent.pbOwnSide.effects[PBEffects::Mist]        = 0
    opponent.pbOwnSide.effects[PBEffects::Safeguard]   = 0
    opponent.pbOwnSide.effects[PBEffects::Spikes]      = 0
    opponent.pbOwnSide.effects[PBEffects::StealthRock] = false
    opponent.pbOwnSide.effects[PBEffects::ToxicSpikes] = 0
    return true
  end
end



################################################################################
# Decreases the target's Attack and Defense by 1 stage each.
################################################################################
class PokeBattle_Move_04A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1}'s attack missed!",attacker.pbThis))
      return -1
    end
    if opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::DEFENSE)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      return -1
    end
    if opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      return -1
    end
    if opponent.hasWorkingAbility(:CLEARBODY) ||
       opponent.hasWorkingAbility(:WHITESMOKE)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=-1; showanim=true
    if opponent.pbReduceStat(PBStats::ATTACK,1,false,showanim)
      ret=0; showanim=false
    end
    if opponent.pbReduceStat(PBStats::DEFENSE,1,false,showanim)
      ret=0; showanim=false
    end
    return ret
  end
end



################################################################################
# Decreases the target's Attack by 2 stages.
################################################################################
class PokeBattle_Move_04B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::ATTACK,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::ATTACK,false)
      opponent.pbReduceStat(PBStats::ATTACK,2,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Defense by 2 stages.
################################################################################
class PokeBattle_Move_04C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::DEFENSE,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::DEFENSE,false)
      opponent.pbReduceStat(PBStats::DEFENSE,2,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Speed by 2 stages.
################################################################################
class PokeBattle_Move_04D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPEED,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPEED,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPEED,false)
      opponent.pbReduceStat(PBStats::SPEED,2,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Special Attack by 2 stages.  Only works on the opposite
# gender.
################################################################################
class PokeBattle_Move_04E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPATK,true)
    if attacker.gender==2 || opponent.gender==2 ||
       attacker.gender==opponent.gender
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.hasWorkingAbility(:OBLIVIOUS)
      @battle.pbDisplay(_INTL("{1}'s {2} prevents romance!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPATK,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if attacker.gender==2 || opponent.gender==2 ||
                    attacker.gender==opponent.gender
    return false if opponent.hasWorkingAbility(:OBLIVIOUS)
    if opponent.pbCanReduceStatStage?(PBStats::SPATK,false)
      opponent.pbReduceStat(PBStats::SPATK,2,false)
    end
    return true
  end
end



################################################################################
# Decreases the target's Special Defense by 2 stages.
################################################################################
class PokeBattle_Move_04F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return super(attacker,opponent,hitnum,alltargets,showanimation) if @basedamage>0
    return -1 if !opponent.pbCanReduceStatStage?(PBStats::SPDEF,true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    ret=opponent.pbReduceStat(PBStats::SPDEF,2,false)
    return ret ? 0 : -1
  end

  def pbAdditionalEffect(attacker,opponent)
    if opponent.pbCanReduceStatStage?(PBStats::SPDEF,false)
      opponent.pbReduceStat(PBStats::SPDEF,2,false)
    end
    return true
  end
end



################################################################################
# Resets all target's stat stages to 0.
################################################################################
class PokeBattle_Move_050 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute
      opponent.stages[PBStats::ATTACK]   = 0
      opponent.stages[PBStats::DEFENSE]  = 0
      opponent.stages[PBStats::SPEED]    = 0
      opponent.stages[PBStats::SPATK]    = 0
      opponent.stages[PBStats::SPDEF]    = 0
      opponent.stages[PBStats::ACCURACY] = 0
      opponent.stages[PBStats::EVASION]  = 0
      @battle.pbDisplay(_INTL("{1}'s stat changes were removed!",opponent.pbThis))
    end
    return ret
  end
end



################################################################################
# Resets all stat stages for all battlers to 0.
################################################################################
class PokeBattle_Move_051 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in 0...4
      @battle.battlers[i].stages[PBStats::ATTACK]   = 0
      @battle.battlers[i].stages[PBStats::DEFENSE]  = 0
      @battle.battlers[i].stages[PBStats::SPEED]    = 0
      @battle.battlers[i].stages[PBStats::SPATK]    = 0
      @battle.battlers[i].stages[PBStats::SPDEF]    = 0
      @battle.battlers[i].stages[PBStats::ACCURACY] = 0
      @battle.battlers[i].stages[PBStats::EVASION]  = 0
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All stat changes were eliminated!"))
    return 0
  end
end



################################################################################
# User and target swap their Attack and Special Attack stat stages.
################################################################################
class PokeBattle_Move_052 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::ATTACK],ostage[PBStats::ATTACK]=ostage[PBStats::ATTACK],astage[PBStats::ATTACK]
    astage[PBStats::SPATK],ostage[PBStats::SPATK]=ostage[PBStats::SPATK],astage[PBStats::SPATK]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Attack and Sp. Atk with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User and target swap their Defense and Special Defense stat stages.
################################################################################
class PokeBattle_Move_053 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    astage=attacker.stages
    ostage=opponent.stages
    astage[PBStats::DEFENSE],ostage[PBStats::DEFENSE]=ostage[PBStats::DEFENSE],astage[PBStats::DEFENSE]
    astage[PBStats::SPDEF],ostage[PBStats::SPDEF]=ostage[PBStats::SPDEF],astage[PBStats::SPDEF]
    @battle.pbDisplay(_INTL("{1} switched all changes to its Defense and Sp. Def with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User and target swap all their stat stages.
################################################################################
class PokeBattle_Move_054 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i],opponent.stages[i]=opponent.stages[i],attacker.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} switched stat changes with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User copies the target's stat stages.
################################################################################
class PokeBattle_Move_055 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      attacker.stages[i]=opponent.stages[i]
    end
    @battle.pbDisplay(_INTL("{1} copied {2}'s stat changes!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# For 5 rounds, user's and ally's stat stages cannot be lowered by foes.
################################################################################
class PokeBattle_Move_056 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Mist]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Your team became shrouded in mist!"))
    else
      @battle.pbDisplay(_INTL("The foe's team became shrouded in mist!"))
    end
    return 0
  end
end



################################################################################
# Swaps the user's Attack and Defense.
################################################################################
class PokeBattle_Move_057 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.attack,attacker.defense=attacker.defense,attacker.attack
    attacker.effects[PBEffects::PowerTrick]=!attacker.effects[PBEffects::PowerTrick]
    @battle.pbDisplay(_INTL("{1} switched its Attack and Defense!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Attack and Special Attack (separately).
################################################################################
class PokeBattle_Move_058 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avatk=((attacker.attack+opponent.attack)/2).floor
    avspatk=((attacker.spatk+opponent.spatk)/2).floor
    attacker.attack=avatk
    opponent.attack=avatk
    attacker.spatk=avspatk
    opponent.spatk=avspatk
    @battle.pbDisplay(_INTL("{1} shared its power with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's Defense and Special Defense (separately).
################################################################################
class PokeBattle_Move_059 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    avdef=((attacker.defense+opponent.defense)/2).floor
    avspdef=((attacker.spdef+opponent.spdef)/2).floor
    attacker.defense=avdef
    opponent.defense=avdef
    attacker.spdef=avspdef
    opponent.spdef=avspdef
    @battle.pbDisplay(_INTL("{1} shared its guard with the target!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Averages the user's and target's current HP.
################################################################################
class PokeBattle_Move_05A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    olda=attacker.hp
    oldo=opponent.hp
    avhp=((attacker.hp+opponent.hp)/2).floor
    attacker.hp=[avhp,attacker.totalhp].min
    opponent.hp=[avhp,opponent.totalhp].min
    @battle.scene.pbHPChanged(attacker,olda)
    @battle.scene.pbHPChanged(opponent,oldo)
    @battle.pbDisplay(_INTL("The battlers shared their pain!"))
    return 0
  end
end



################################################################################
# For 4 more rounds, doubles the Speed of all battlers on the user's side.
################################################################################
class PokeBattle_Move_05B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Tailwind]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Tailwind]=4
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The tailwind blew from behind your team!"))
    else
      @battle.pbDisplay(_INTL("The tailwind blew from behind the opposing team!"))
    end
    return 0
  end
end



################################################################################
# This move turns into the last move used by the target, until user switches out.
################################################################################
class PokeBattle_Move_05C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x14,   # Chatter
       0x5C,   # Mimic
       0x5D,   # Sketch
       0xB6    # Metronome
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsed<=0 ||
       isConst?(PBMoveData.new(opponent.lastMoveUsed).type,PBTypes,:SHADOW) ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsed)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove)
        movename=PBMoves.getName(opponent.lastMoveUsed)
        @battle.pbDisplay(_INTL("{1} learned {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# This move permanently turns into the last move used by the target.
################################################################################
class PokeBattle_Move_05D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,   # Struggle
       0x14,   # Chatter
       0x5D    # Sketch
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.lastMoveUsedSketch<=0 ||
       isConst?(PBMoveData.new(opponent.lastMoveUsedSketch).type,PBTypes,:SHADOW) ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsedSketch).function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in attacker.moves
      if i.id==opponent.lastMoveUsedSketch
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1 
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    for i in 0...attacker.moves.length
      if attacker.moves[i].id==@id
        newmove=PBMove.new(opponent.lastMoveUsedSketch)
        attacker.moves[i]=PokeBattle_Move.pbFromPBMove(@battle,newmove)
        party=@battle.pbParty(attacker.index)
        party[attacker.pokemonIndex].moves[i]=newmove
        movename=PBMoves.getName(opponent.lastMoveUsedSketch)
        @battle.pbDisplay(_INTL("{1} sketched {2}!",attacker.pbThis,movename))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Changes user's type to that of a random move of the user, ignoring this one.
################################################################################
class PokeBattle_Move_05E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    for i in attacker.moves
      next if i.id==@id
      next if PBTypes.isPseudoType?(i.type)
      next if attacker.pbHasType?(i.type)
      found=false
      types.push(i.type) if !types.include?(i.type)
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.type1=newtype
    attacker.type2=newtype
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
  end
end



################################################################################
# Changes user's type to a random one that resists the last attack used by target.
################################################################################
class PokeBattle_Move_05F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       PBTypes.isPseudoType?(PBMoveData.new(opponent.lastMoveUsed).type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    types=[]
    atype=-1
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed
        atype=i.pbType
        break
      end
    end
    if atype<0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in 0..PBTypes.maxValue
      next if attacker.pbHasType?(i)
      types.push(i) if PBTypes.getEffectiveness(atype,i)<2 
    end
    if types.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    newtype=types[@battle.pbRandom(types.length)]
    attacker.type1=newtype
    attacker.type2=newtype
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))
    return 0
  end
end



################################################################################
# Changes user's type depending on the environment.
################################################################################
class PokeBattle_Move_060 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    envtypes=[
       :NORMAL, # None
       :GRASS,  # Grass
       :GRASS,  # Tall grass
       :WATER,  # Moving water
       :WATER,  # Still water
       :WATER,  # Underwater
       :ROCK,   # Rock
       :ROCK,   # Cave
       :GROUND  # Sand
    ]
    type=envtypes[@battle.environment]
    if attacker.pbHasType?(type)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newtype=getConst(PBTypes,type) || 0
    attacker.type1=newtype
    attacker.type2=newtype
    typename=PBTypes.getName(newtype)
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",attacker.pbThis,typename))  
    return 0
  end
end



################################################################################
# Target becomes Water type.
################################################################################
class PokeBattle_Move_061 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.type1=getConst(PBTypes,:WATER)
    opponent.type2=getConst(PBTypes,:WATER)
    typename=PBTypes.getName(getConst(PBTypes,:WATER))
    @battle.pbDisplay(_INTL("{1} transformed into the {2} type!",opponent.pbThis,typename))
    return 0
  end
end



################################################################################
# User copes target's types.
################################################################################
class PokeBattle_Move_062 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if isConst?(attacker.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.pbHasType?(opponent.type1) &&
       attacker.pbHasType?(opponent.type2) &&
       opponent.pbHasType?(attacker.type1) &&
       opponent.pbHasType?(attacker.type2)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
    @battle.pbDisplay(_INTL("{1}'s type changed to match {2}'s!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Target's ability becomes Simple.
################################################################################
class PokeBattle_Move_063 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:SIMPLE) ||
       isConst?(opponent.ability,PBAbilities,:TRUANT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=getConst(PBAbilities,:SIMPLE) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:SIMPLE))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    return 0
  end
end



################################################################################
# Target's ability becomes Insomnia.
################################################################################
class PokeBattle_Move_064 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:INSOMNIA) ||
       isConst?(opponent.ability,PBAbilities,:TRUANT)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=getConst(PBAbilities,:INSOMNIA) || 0
    abilityname=PBAbilities.getName(getConst(PBAbilities,:INSOMNIA))
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    return 0
  end
end



################################################################################
# User copes target's ability.
################################################################################
class PokeBattle_Move_065 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.ability==0 ||
       attacker.ability==opponent.ability ||
       isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:FLOWERGIFT) ||
       isConst?(opponent.ability,PBAbilities,:FORECAST) ||
       isConst?(opponent.ability,PBAbilities,:ILLUSION) ||
       isConst?(opponent.ability,PBAbilities,:IMPOSTER) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:TRACE) ||
       isConst?(opponent.ability,PBAbilities,:WONDERGUARD) ||
       isConst?(opponent.ability,PBAbilities,:ZENMODE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.ability=opponent.ability
    abilityname=PBAbilities.getName(opponent.ability)
    @battle.pbDisplay(_INTL("{1} copied {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),abilityname))
    return 0
  end
end



################################################################################
# Target copies user's ability.
################################################################################
class PokeBattle_Move_066 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if attacker.ability==0 ||
       attacker.ability==opponent.ability ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:TRUANT) ||
       isConst?(attacker.ability,PBAbilities,:FLOWERGIFT) ||
       isConst?(attacker.ability,PBAbilities,:FORECAST) ||
       isConst?(attacker.ability,PBAbilities,:ILLUSION) ||
       isConst?(attacker.ability,PBAbilities,:IMPOSTER) ||
       isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:TRACE) ||
       isConst?(attacker.ability,PBAbilities,:ZENMODE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.ability=attacker.ability
    abilityname=PBAbilities.getName(attacker.ability)
    @battle.pbDisplay(_INTL("{1} acquired {2}!",opponent.pbThis,abilityname))
    return 0
  end
end



################################################################################
# User and target swap abilities.
################################################################################
class PokeBattle_Move_067 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if (attacker.ability==0 && opponent.ability==0) ||
       attacker.ability==opponent.ability ||
       isConst?(attacker.ability,PBAbilities,:ILLUSION) ||
       isConst?(opponent.ability,PBAbilities,:ILLUSION) ||
       isConst?(attacker.ability,PBAbilities,:MULTITYPE) ||
       isConst?(opponent.ability,PBAbilities,:MULTITYPE) ||
       isConst?(attacker.ability,PBAbilities,:WONDERGUARD) ||
       isConst?(opponent.ability,PBAbilities,:WONDERGUARD)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    tmp=attacker.ability
    attacker.ability=opponent.ability
    opponent.ability=tmp
    @battle.pbDisplay(_INTL("{1} swapped its {2} ability with its target's {3} ability!",
       attacker.pbThis,PBAbilities.getName(opponent.ability),
       PBAbilities.getName(attacker.ability)))
    attacker.pbAbilitiesOnSwitchIn(true)
    opponent.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end



################################################################################
# Target's ability is negated.
################################################################################
class PokeBattle_Move_068 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if isConst?(opponent.ability,PBAbilities,:MULTITYPE)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::GastroAcid]=true
    opponent.effects[PBEffects::Truant]=false
    @battle.pbDisplay(_INTL("{1}'s ability was suppressed!",opponent.pbThis)) 
    return 0
  end
end



################################################################################
# User transforms into the target.
################################################################################
class PokeBattle_Move_069 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0xC9,   # Fly
       0xCA,   # Dig
       0xCB,   # Dive
       0xCC,   # Bounce
       0xCD,   # Shadow Force
       0xCE    # Sky Drop
    ]
    if attacker.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Transform] ||
       opponent.effects[PBEffects::Substitute]>0 ||
       blacklist.include?(PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Transform]=true
    attacker.species=opponent.species
    attacker.type1=opponent.type1
    attacker.type2=opponent.type2
#    attacker.ability=opponent.ability
    attacker.attack=opponent.attack
    attacker.defense=opponent.defense
    attacker.speed=opponent.speed
    attacker.spatk=opponent.spatk
    attacker.spdef=opponent.spdef
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::EVASION,PBStats::ACCURACY]
      attacker.stages[i]=opponent.stages[i]
    end
    for i in 0...4
      attacker.moves[i]=PokeBattle_Move.pbFromPBMove(
         @battle,PBMove.new(opponent.moves[i].id))
      attacker.moves[i].pp=5
      attacker.moves[i].totalpp=5
    end
    attacker.effects[PBEffects::Disable]=0
    attacker.effects[PBEffects::DisableMove]=0
    @battle.pbDisplay(_INTL("{1} transformed into {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Inflicts a fixed 20HP damage.
################################################################################
class PokeBattle_Move_06A < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(20,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts a fixed 40HP damage.
################################################################################
class PokeBattle_Move_06B < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(40,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Halves the target's current HP.
################################################################################
class PokeBattle_Move_06C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage((opponent.hp/2).floor,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage equal to the user's level.
################################################################################
class PokeBattle_Move_06D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return pbEffectFixedDamage(attacker.level,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage to bring the target's HP down to equal the user's HP.
################################################################################
class PokeBattle_Move_06E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp>=opponent.hp
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    return pbEffectFixedDamage(opponent.hp-attacker.hp,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Inflicts damage between 0.5 and 1.5 times the user's level.
################################################################################
class PokeBattle_Move_06F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    dmg=(attacker.level*(@battle.pbRandom(101)+50)/100).floor
    return pbEffectFixedDamage(dmg,attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# OHKO.  Accuracy increases by difference between levels of user and target.
################################################################################
class PokeBattle_Move_070 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    if opponent.hasWorkingAbility(:STURDY)
      @battle.pbDisplay(_INTL("{1} was protected by {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return false
    end
    if opponent.level>attacker.level
      @battle.pbDisplay(_INTL("{1} is unaffected!",opponent.pbThis))
      return false
    end
    acc=@accuracy+attacker.level-opponent.level
    return @battle.pbRandom(100)<acc
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    damage=pbEffectFixedDamage(opponent.totalhp,attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.isFainted?
      @battle.pbDisplay(_INTL("It's a one-hit KO!"))
    end
    return damage
  end
end


################################################################################
# Counters a physical move used against the user this round, with 2x the power.
################################################################################
class PokeBattle_Move_071 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::CounterTarget]>=0 &&
       attacker.pbIsOpposing?(attacker.effects[PBEffects::CounterTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::CounterTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Counter]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::Counter]*2,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# Counters a specical move used against the user this round, with 2x the power.
################################################################################
class PokeBattle_Move_072 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::MirrorCoatTarget]>=0 && 
       attacker.pbIsOpposing?(attacker.effects[PBEffects::MirrorCoatTarget])
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::MirrorCoatTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::MirrorCoat]<=0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::MirrorCoat]*2,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# Counters the last damaging move used against the user this round, with 1.5x
# the power.
################################################################################
class PokeBattle_Move_073 < PokeBattle_Move
  def pbAddTarget(targets,attacker)
    if attacker.lastAttacker>=0 && attacker.pbIsOpposing?(attacker.lastAttacker)
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.lastAttacker])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.lastHPLost==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage((attacker.lastHPLost*1.5).floor,attacker,opponent,hitnum,alltargets,showanimation)
    return ret
  end
end



################################################################################
# The target's ally loses 1/16 of its max HP.
################################################################################
class PokeBattle_Move_074 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Power is doubled if the target is using Dive.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_075 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the target is using Dig.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_076 < PokeBattle_Move
  def pbModifyDamage(damagemult,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_077 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target is using Bounce, Fly or Sky Drop.
# May make the target flinch.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_078 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
       PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
      return basedmg*2
    end
    return basedmg
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end



################################################################################
# Power is doubled if the target has already used Fusion Flare this round.
################################################################################
class PokeBattle_Move_079 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamageMultiplier
end



################################################################################
# Power is doubled if the target has already used Fusion Bolt this round.
################################################################################
class PokeBattle_Move_07A < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamageMultiplier
end



################################################################################
# Power is doubled if the target is poisoned.
################################################################################
class PokeBattle_Move_07B < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if opponent.status==PBStatuses::POISON &&
       opponent.effects[PBEffects::Substitute]==0
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the target is paralyzed.  Cures the target of paralysis.
################################################################################
class PokeBattle_Move_07C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::PARALYSIS &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       opponent.status==PBStatuses::PARALYSIS
      opponent.status=0
      @battle.pbDisplay(_INTL("{1} was cured of paralysis.",opponent.pbThis))
    end
    return ret
  end
end



################################################################################
# Power is doubled if the target is asleep.  Wakes the target up.
################################################################################
class PokeBattle_Move_07D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status==PBStatuses::SLEEP &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       opponent.status==PBStatuses::SLEEP
      opponent.pbCureStatus
    end
    return ret
  end
end



################################################################################
# Power is doubled if the user is burned, poisoned or paralyzed.
################################################################################
class PokeBattle_Move_07E < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if attacker.status==PBStatuses::POISON ||
       attacker.status==PBStatuses::BURN ||
       attacker.status==PBStatuses::PARALYSIS
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the target has a status problem.
################################################################################
class PokeBattle_Move_07F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.status>0 &&
       opponent.effects[PBEffects::Substitute]==0
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target's HP is down to 1/2 or less.
################################################################################
class PokeBattle_Move_080 < PokeBattle_Move
  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if opponent.hp<=opponent.totalhp/2
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# Power is doubled if the user has lost HP due to the target's move this round.
################################################################################
class PokeBattle_Move_081 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if attacker.lastHPLost>0 && attacker.lastAttacker==opponent.index
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the target has already lost HP this round.
################################################################################
class PokeBattle_Move_082 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if opponent.lastHPLost>0
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled if the user's ally has already used this move this round.
# This move goes immediately after the ally, ignoring priority.
################################################################################
class PokeBattle_Move_083 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamage
end



################################################################################
# Power is doubled if the target has already moved this round.
################################################################################
class PokeBattle_Move_084 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamage
end



################################################################################
# Power is doubled if a user's teammate fainted last round.
################################################################################
class PokeBattle_Move_085 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamageMultiplier
end



################################################################################
# Power is doubled if the user has no held item.
################################################################################
class PokeBattle_Move_086 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    # TODO: Should also double damage if held item is a Gem that will be consumed
    if attacker.item==0
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power is doubled in weather.  Type changes depending on the weather.
################################################################################
class PokeBattle_Move_087 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.pbWeather!=0
      return basedmg*2
    end
    return basedmg
  end

  def pbType(type,attacker,opponent)
    weather=@battle.pbWeather
    type=getConst(PBTypes,:NORMAL) || 0
    type=(getConst(PBTypes,:FIRE) || type) if weather==PBWeather::SUNNYDAY
    type=(getConst(PBTypes,:WATER) || type) if weather==PBWeather::RAINDANCE
    type=(getConst(PBTypes,:ROCK) || type) if weather==PBWeather::SANDSTORM
    type=(getConst(PBTypes,:ICE)  || type) if weather==PBWeather::HAIL
    return type
  end
end



################################################################################
# Power is doubled if a foe tries to switch out.
# (Handled in Battle's pbAttackPhase): Makes this attack happen before switching.
################################################################################
class PokeBattle_Move_088 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    if @battle.switching
      return basedmg*2
    end
    return basedmg
  end
end



################################################################################
# Power increases with the user's happiness.
################################################################################
class PokeBattle_Move_089 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(attacker.happiness*2/5).floor,1].max
  end
end



################################################################################
# Power decreases with the user's happiness.
################################################################################
class PokeBattle_Move_08A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [((255-attacker.happiness)*2/5).floor,1].max
  end
end



################################################################################
# Power increases with the user's HP.
################################################################################
class PokeBattle_Move_08B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(150*attacker.hp/attacker.totalhp).floor,1].max
  end
end



################################################################################
# Power increases with the target's HP.
################################################################################
class PokeBattle_Move_08C < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [(120*opponent.hp/opponent.totalhp).floor,1].max
  end
end



################################################################################
# Power increases the quicker the target is than the user.
################################################################################
class PokeBattle_Move_08D < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return [[(25*opponent.pbSpeed/attacker.pbSpeed).floor,150].min,1].max
  end
end



################################################################################
# Power increases with the user's positive stat changes (ignores negative ones).
################################################################################
class PokeBattle_Move_08E < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=0
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      mult+=attacker.stages[i] if attacker.stages[i]>0
    end
    return 20*(mult+1)
  end
end



################################################################################
# Power increases with the target's positive stat changes (ignores negative ones).
################################################################################
class PokeBattle_Move_08F < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    mult=0
    for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,
              PBStats::SPATK,PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
      mult+=opponent.stages[i] if opponent.stages[i]>0
    end
    return [20*(mult+3),200].min
  end
end



################################################################################
# Power and type depends on the user's IVs.
################################################################################
class PokeBattle_Move_090 < PokeBattle_Move
  def pbType(type,attacker,opponent)
    hp=pbHiddenPower(attacker.iv)
    return hp[0]
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    hp=pbHiddenPower(attacker.iv)
    return hp[1]
  end
end

def pbHiddenPower(iv)
  powermin=30
  powermax=70
  type=0; base=0
  types=[]
  for i in 0..PBTypes.maxValue
    types.push(i) if !PBTypes.isPseudoType?(i) &&
                     !isConst?(i,PBTypes,:NORMAL) && !isConst?(i,PBTypes,:SHADOW)
  end
  type|=(iv[PBStats::HP]&1)
  type|=(iv[PBStats::ATTACK]&1)<<1
  type|=(iv[PBStats::DEFENSE]&1)<<2
  type|=(iv[PBStats::SPEED]&1)<<3
  type|=(iv[PBStats::SPATK]&1)<<4
  type|=(iv[PBStats::SPDEF]&1)<<5
  type=(type*(types.length-1)/63).floor
  hptype=types[type]
  base|=(iv[PBStats::HP]&2)>>1
  base|=(iv[PBStats::ATTACK]&2)
  base|=(iv[PBStats::DEFENSE]&2)<<1
  base|=(iv[PBStats::SPEED]&2)<<2
  base|=(iv[PBStats::SPATK]&2)<<3
  base|=(iv[PBStats::SPDEF]&2)<<4
  base=(base*(powermax-powermin)/63).floor+powermin
  return [hptype,base]
end

################################################################################
# Power doubles for each consecutive use.
################################################################################
class PokeBattle_Move_091 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg=basedmg<<(attacker.effects[PBEffects::FuryCutter]-1) # can be 1 to 4
    return basedmg
  end
end



################################################################################
# Power doubles for each consecutive use.
################################################################################
class PokeBattle_Move_092 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    basedmg*=attacker.effects[PBEffects::EchoedVoice] # can be 1 to 5
    return basedmg
  end
end



################################################################################
# User rages until the start of a round in which they don't use this move.
# Handled in Battler class: Ups rager's Attack by 1 stage each time it loses HP due to a move.
################################################################################
class PokeBattle_Move_093 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Rage]=true if ret>0
    return ret
  end
end



################################################################################
# Randomly damages or heals the target.
################################################################################
class PokeBattle_Move_094 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return @calcbasedmg 
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    @calcbasedmg=1
    r=@battle.pbRandom(10)
    if r<4
      @calcbasedmg=40
    elsif r<7
      @calcbasedmg=80
    elsif r<8
      @calcbasedmg=120
    else
      if pbTypeModifier(@type,attacker,opponent)==0
        @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
        return -1
      end
      if opponent.hp==opponent.totalhp
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      damage=pbCalcDamage(attacker,opponent) # Must do this even if it will heal
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation) # Healing animation
      opponent.pbRecoverHP([1,(opponent.totalhp/4).floor].max,true)
      @battle.pbDisplay(_INTL("{1} had its HP restored.",opponent.pbThis))   
      return 0
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# Power is chosen at random.  Power is doubled if the target is using Dig.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_095 < PokeBattle_Move
  @calcbasedmg=0

  def pbOnStartUse(attacker)
    basedmg=[10,30,50,70,90,110,150]
    magnitudes=[
       4,
       5,5,
       6,6,6,6,
       7,7,7,7,7,7,
       8,8,8,8,
       9,9,
       10
    ]
    magni=magnitudes[@battle.pbRandom(magnitudes.length)]
    @calcbasedmg=basedmg[magni-4]
    @battle.pbDisplay(_INTL("Magnitude {1}!",magni))
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCA # Dig
      return @calcbasedmg*2
    end
    return @calcbasedmg
  end
end



################################################################################
# Power and type depend on the user's held berry.  Destroys the berry.
################################################################################
class PokeBattle_Move_096 < PokeBattle_Move
  @berry=0

  def pbOnStartUse(attacker)
    if !pbIsBerry?(attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    @berry=attacker.item
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    attacker.pokemon.itemRecycle=attacker.item
    attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
    attacker.item=0
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    damagearray={
       60 => [:CHERIBERRY,:CHESTOBERRY,:PECHABERRY,:RAWSTBERRY,:ASPEARBERRY,
              :LEPPABERRY,:ORANBERRY,:PERSIMBERRY,:LUMBERRY,:SITRUSBERRY,
              :FIGYBERRY,:WIKIBERRY,:MAGOBERRY,:AGUAVBERRY,:IAPAPABERRY,
              :RAZZBERRY,:OCCABERRY,:PASSHOBERRY,:WACANBERRY,:RINDOBERRY,
              :YACHEBERRY,:CHOPLEBERRY,:KEBIABERRY,:SHUCABERRY,:COBABERRY,
              :PAYAPABERRY,:TANGABERRY,:CHARTIBERRY,:KASIBBERRY,:HABANBERRY,
              :COLBURBERRY,:BABIRIBERRY,:CHILANBERRY],
       70 => [:BLUKBERRY,:NANABBERRY,:WEPEARBERRY,:PINAPBERRY,:POMEGBERRY,
              :KELPSYBERRY,:QUALOTBERRY,:HONDEWBERRY,:GREPABERRY,:TAMATOBERRY,
              :CORNNBERRY,:MAGOSTBERRY,:RABUTABERRY,:NOMELBERRY,:SPELONBERRY,
              :PAMTREBERRY],
       80 => [:WATMELBERRY,:DURINBERRY,:BELUEBERRY,:LIECHIBERRY,:GANLONBERRY,
              :SALACBERRY,:PETAYABERRY,:APICOTBERRY,:LANSATBERRY,:STARFBERRY,
              :ENIGMABERRY,:MICLEBERRY,:CUSTAPBERRY,:JACOBABERRY,:ROWAPBERRY]
    }
    for i in damagearray.keys
      data=damagearray[i]
      if data
        for j in data
          return i if isConst?(@berry,PBItems,j)
        end
      end
    end
    return 1
  end

  def pbType(type,attacker,opponent)
    typearray={
       :NORMAL   => [:CHILANBERRY],
       :FIRE     => [:CHERIBERRY,:BLUKBERRY,:WATMELBERRY,:OCCABERRY],
       :WATER    => [:CHESTOBERRY,:NANABBERRY,:DURINBERRY,:PASSHOBERRY],
       :ELECTRIC => [:PECHABERRY,:WEPEARBERRY,:BELUEBERRY,:WACANBERRY],
       :GRASS    => [:RAWSTBERRY,:PINAPBERRY,:RINDOBERRY,:LIECHIBERRY],
       :ICE      => [:ASPEARBERRY,:POMEGBERRY,:YACHEBERRY,:GANLONBERRY],
       :FIGHTING => [:LEPPABERRY,:KELPSYBERRY,:CHOPLEBERRY,:SALACBERRY],
       :POISON   => [:ORANBERRY,:QUALOTBERRY,:KEBIABERRY,:PETAYABERRY],
       :GROUND   => [:PERSIMBERRY,:HONDEWBERRY,:SHUCABERRY,:APICOTBERRY],
       :FLYING   => [:LUMBERRY,:GREPABERRY,:COBABERRY,:LANSATBERRY],
       :PSYCHIC  => [:SITRUSBERRY,:TAMATOBERRY,:PAYAPABERRY,:STARFBERRY],
       :BUG      => [:FIGYBERRY,:CORNNBERRY,:TANGABERRY,:ENIGMABERRY],
       :ROCK     => [:WIKIBERRY,:MAGOSTBERRY,:CHARTIBERRY,:MICLEBERRY],
       :GHOST    => [:MAGOBERRY,:RABUTABERRY,:KASIBBERRY,:CUSTAPBERRY],
       :DRAGON   => [:AGUAVBERRY,:NOMELBERRY,:HABANBERRY,:JACOBABERRY],
       :DARK     => [:IAPAPABERRY,:SPELONBERRY,:COLBURBERRY,:ROWAPBERRY],
       :STEEL    => [:RAZZBERRY,:PAMTREBERRY,:BABIRIBERRY]
    }
    for i in typearray.keys
      data=typearray[i]
      if data
        for j in data
          return getConst(PBTypes,i) if isConst?(@berry,PBItems,j)
        end
      end
    end
    return getConst(PBTypes,:NORMAL)
  end
end



################################################################################
# Power increases the less PP this move has.
################################################################################
class PokeBattle_Move_097 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    dmgs=[200,80,60,50,40]
    ppleft=[@pp,4].min   # PP is reduced before the move is used
    basedmg=dmgs[ppleft]
    return basedmg
  end
end



################################################################################
# Power increases the less HP the user has.
################################################################################
class PokeBattle_Move_098 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(48*attacker.hp/attacker.totalhp).floor
    ret=20
    ret=40 if n<33
    ret=80 if n<17
    ret=100 if n<10
    ret=150 if n<5
    ret=200 if n<2
    return ret
  end
end



################################################################################
# Power increases the quicker the user is than the target.
################################################################################
class PokeBattle_Move_099 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(attacker.pbSpeed/opponent.pbSpeed).floor
    ret=40
    ret=60 if n>=1
    ret=80 if n>=2
    ret=120 if n>=3
    ret=150 if n>=4
    return ret
  end
end



################################################################################
# Power increases the heavier the target is.
################################################################################
class PokeBattle_Move_09A < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    weight=opponent.weight
    ret=20
    ret=40 if weight>100
    ret=60 if weight>250
    ret=80 if weight>500
    ret=100 if weight>1000
    ret=120 if weight>2000
    return ret
  end
end



################################################################################
# Power increases the heavier the user is than the target.
################################################################################
class PokeBattle_Move_09B < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    n=(attacker.weight/opponent.weight).floor
    ret=40
    ret=60 if n>=2
    ret=80 if n>=3
    ret=100 if n>=4
    ret=120 if n>=5
    return ret
  end
end



################################################################################
# Powers up the ally's attack this round by 1.5.
################################################################################
class PokeBattle_Move_09C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbPartner.isFainted? ||
       attacker.pbPartner.effects[PBEffects::HelpingHand]
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,attacker.pbPartner,hitnum,alltargets,showanimation)
    attacker.pbPartner.effects[PBEffects::HelpingHand]=true
    @battle.pbDisplay(_INTL("{1} is ready to help {2}!",attacker.pbThis,attacker.pbPartner.pbThis(true)))
    return 0
  end
end



################################################################################
# Weakens Electric attacks.
################################################################################
class PokeBattle_Move_09D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in 0...4
      if attacker.battle.battlers[i].effects[PBEffects::MudSport]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MudSport]=true
    @battle.pbDisplay(_INTL("Electricity's power was weakened!"))
    return 0
  end
end



################################################################################
# Weakens Fire attacks.
################################################################################
class PokeBattle_Move_09E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in 0...4
      if attacker.battle.battlers[i].effects[PBEffects::WaterSport]
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::WaterSport]=true
    @battle.pbDisplay(_INTL("Fire's power was weakened!"))
    return 0
  end
end



################################################################################
# Type depends on the user's held item.
################################################################################
class PokeBattle_Move_09F < PokeBattle_Move
  def pbType(type,attacker,opponent)
    if isConst?(@id,PBMoves,:JUDGMENT)
      return getConst(PBTypes,:FIGHTING) if attacker.hasWorkingItem(:FISTPLATE)
      return getConst(PBTypes,:FLYING)   if attacker.hasWorkingItem(:SKYPLATE)
      return getConst(PBTypes,:POISON)   if attacker.hasWorkingItem(:TOXICPLATE)
      return getConst(PBTypes,:GROUND)   if attacker.hasWorkingItem(:EARTHPLATE)
      return getConst(PBTypes,:ROCK)     if attacker.hasWorkingItem(:STONEPLATE)
      return getConst(PBTypes,:BUG)      if attacker.hasWorkingItem(:INSECTPLATE)
      return getConst(PBTypes,:GHOST)    if attacker.hasWorkingItem(:SPOOKYPLATE)
      return getConst(PBTypes,:STEEL)    if attacker.hasWorkingItem(:IRONPLATE)
      return getConst(PBTypes,:FIRE)     if attacker.hasWorkingItem(:FLAMEPLATE)
      return getConst(PBTypes,:WATER)    if attacker.hasWorkingItem(:SPLASHPLATE)
      return getConst(PBTypes,:GRASS)    if attacker.hasWorkingItem(:MEADOWPLATE)
      return getConst(PBTypes,:ELECTRIC) if attacker.hasWorkingItem(:ZAPPLATE)
      return getConst(PBTypes,:PSYCHIC)  if attacker.hasWorkingItem(:MINDPLATE)
      return getConst(PBTypes,:ICE)      if attacker.hasWorkingItem(:ICICLEPLATE)
      return getConst(PBTypes,:DRAGON)   if attacker.hasWorkingItem(:DRACOPLATE)
      return getConst(PBTypes,:DARK)     if attacker.hasWorkingItem(:DREADPLATE)
    elsif isConst?(@id,PBMoves,:TECHNOBLAST)
      return getConst(PBTypes,:ELECTRIC) if attacker.hasWorkingItem(:SHOCKDRIVE)
      return getConst(PBTypes,:FIRE)     if attacker.hasWorkingItem(:BURNDRIVE)
      return getConst(PBTypes,:ICE)      if attacker.hasWorkingItem(:CHILLDRIVE)
      return getConst(PBTypes,:WATER)    if attacker.hasWorkingItem(:DOUSEDRIVE)
    end
    return getConst(PBTypes,:NORMAL)
  end
end



################################################################################
# This attack is always a critical hit, if successful.
################################################################################
class PokeBattle_Move_0A0 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# For 5 rounds, foes' attacks cannot become critical hits.
################################################################################
class PokeBattle_Move_0A1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LuckyChant]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LuckyChant]=5
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("The Lucky Chant shielded your team from critical hits!"))
    else
      @battle.pbDisplay(_INTL("The Lucky Chant shielded the foe's team from critical hits!"))
    end  
    return 0
  end
end



################################################################################
# For 5 rounds, lowers power of physical attacks against the user's side.
################################################################################
class PokeBattle_Move_0A2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::Reflect]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::Reflect]=5
    attacker.pbOwnSide.effects[PBEffects::Reflect]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Reflect raised your team's Defense!"))
    else
      @battle.pbDisplay(_INTL("Reflect raised the opposing team's Defense!"))
    end  
    return 0
  end
end



################################################################################
# For 5 rounds, lowers power of special attacks against the user's side.
################################################################################
class PokeBattle_Move_0A3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOwnSide.effects[PBEffects::LightScreen]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=5
    attacker.pbOwnSide.effects[PBEffects::LightScreen]=8 if attacker.hasWorkingItem(:LIGHTCLAY)
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Light Screen raised your team's Special Defense!"))
    else
      @battle.pbDisplay(_INTL("Light Screen raised the opposing team's Special Defense!"))
    end
    return 0
  end
end



################################################################################
# Effect depends on the environment.
################################################################################
class PokeBattle_Move_0A4 < PokeBattle_Move
  def pbAdditionalEffect(attacker,opponent)
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass
      return false if !opponent.pbCanSleep?(false)
      opponent.pbSleep
      @battle.pbDisplay(_INTL("{1} went to sleep!",opponent.pbThis))  
    when PBEnvironment::MovingWater
      return false if !opponent.pbCanReduceStatStage?(PBStats::ATTACK,1,false)
      opponent.pbReduceStat(PBStats::ATTACK,1,false)
    when PBEnvironment::StillWater
      return false if !opponent.pbCanReduceStatStage?(PBStats::SPEED,1,false)
      opponent.pbReduceStat(PBStats::SPEED,1,false)
    when PBEnvironment::Underwater
      return false if !opponent.pbCanReduceStatStage?(PBStats::DEFENSE,1,false)
      opponent.pbReduceStat(PBStats::DEFENSE,1,false)
    when PBEnvironment::Cave, PBEnvironment::Rock
      return false if opponent.hasWorkingAbility(:INNERFOCUS) ||
         opponent.effects[PBEffects::Substitute]>0
      opponent.effects[PBEffects::Flinch]=true
    when PBEnvironment::Sand
      return false if !opponent.pbCanReduceStatStage?(PBStats::ACCURACY,1,false)
      opponent.pbReduceStat(PBStats::ACCURACY,1,false)
    else
      return false if !opponent.pbCanParalyze?(false)
      opponent.pbParalyze(attacker)
      @battle.pbDisplay(_INTL("{1} is paralyzed!  It may be unable to move!",opponent.pbThis))
    end
    return true
  end
end



################################################################################
# Always hits.
################################################################################
class PokeBattle_Move_0A5 < PokeBattle_Move
  def pbAccuracyCheck(attacker,opponent)
    return true
  end
end



################################################################################
# User's attack next round against the target will definitely hit.
################################################################################
class PokeBattle_Move_0A6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LockOn]=2
    opponent.effects[PBEffects::LockOnPos]=attacker.index
    @battle.pbDisplay(_INTL("{1} took aim at {2}!",attacker.pbThis,opponent.pbThis(true)))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on.
# Normal and Fighting moves have normal effectiveness against the Ghost-type target.
################################################################################
class PokeBattle_Move_0A7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Foresight]
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Foresight]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target's evasion stat changes are ignored from now on.
# Psychic moves have normal effectiveness against the Dark-type target.
################################################################################
class PokeBattle_Move_0A8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::MiracleEye]
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MiracleEye]=true
    @battle.pbDisplay(_INTL("{1} was identified!",opponent.pbThis))
    return 0
  end
end



################################################################################
# This move ignores target's Defense, Special Defense and evasion stat changes.
################################################################################
class PokeBattle_Move_0A9 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# User is protected against moves with the "B" flag this round.
################################################################################
class PokeBattle_Move_0AA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8    # Endure
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    #TODO: Fails if this is the last attack in the round
    if @battle.pbRandom(65536)>(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Protect]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} protected itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User's side is protected against moves with priority greater than 0 this round.
################################################################################
class PokeBattle_Move_0AB < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# User's side is protected against moves that target multiple battlers this round.
################################################################################
class PokeBattle_Move_0AC < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Ignores target's protections.  If successful, all other moves this round
# ignore them too.
################################################################################
class PokeBattle_Move_0AD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    return ret
  end
end



################################################################################
# Uses the last move that the target used.
################################################################################
class PokeBattle_Move_0AE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.lastMoveUsed<=0 ||
       (PBMoveData.new(opponent.lastMoveUsed).flags&0x10)==0 # flag e: Copyable by Mirror Move
      @battle.pbDisplay(_INTL("The mirror move failed!"))
      return -1
    end
    attacker.pbUseMoveSimple(opponent.lastMoveUsed,-1,opponent.index)
    return 0
  end
end



################################################################################
# Uses the last move that was used.
################################################################################
class PokeBattle_Move_0AF < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Uses the move the target was about to use this round, with 1.5x power.
################################################################################
class PokeBattle_Move_0B0 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# This round, reflects all moves with the "C" flag targeting the user back at
# their origin.
################################################################################
class PokeBattle_Move_0B1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagicCoat]=true
    @battle.pbDisplay(_INTL("{1} shrouded itself with Magic Coat!",attacker.pbThis))
    return 0
  end
end



################################################################################
# This round, snatches all used moves with the "D" flag.
################################################################################
class PokeBattle_Move_0B2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    # TODO: Fails if attacker is last in priority
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Snatch]=true
    @battle.pbDisplay(_INTL("{1} waits for a target to make a move!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Uses a different move depending on the environment.
################################################################################
class PokeBattle_Move_0B3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    move=0
    case @battle.environment
    when PBEnvironment::Grass, PBEnvironment::TallGrass
      move=getConst(PBMoves,:SEEDBOMB) || 0
    when PBEnvironment::MovingWater, PBEnvironment::Underwater
      move=getConst(PBMoves,:HYDROPUMP) || 0
    when PBEnvironment::StillWater
      move=getConst(PBMoves,:MUDBOMB) || 0
    when PBEnvironment::Rock, PBEnvironment::Cave
      move=getConst(PBMoves,:ROCKSLIDE) || 0
    when PBEnvironment::Sand
      move=getConst(PBMoves,:EARTHQUAKE) || 0
    else
      move=getConst(PBMoves,:TRIATTACK) || 0
    end
    if move==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    thismovename=PBMoves.getName(@id)
    movename=PBMoves.getName(move)
    @battle.pbDisplay(_INTL("{1} turned into {2}!",thismovename,movename))
    attacker.pbUseMoveSimple(move)
    return 0
  end
end



################################################################################
# Uses a random move the user knows.  Fails if user is not asleep.
################################################################################
class PokeBattle_Move_0B4 < PokeBattle_Move
  def pbCanUseWhileAsleep?
    return true
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.status!=PBStatuses::SLEEP
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end 
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x5D,    # Sketch
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xD1,    # Uproar
       0xD4,    # Bide
       0x115,   # Focus Punch
# Two-turn attacks
       0xC3,    # Razor Wind
       0xC4,    # SolarBeam
       0xC5,    # Freeze Shock
       0xC6,    # Ice Burn
       0xC7,    # Sky Attack
       0xC8,    # Skull Bash
       0xC9,    # Fly
       0xCA,    # Dig
       0xCB,    # Dive
       0xCC,    # Bounce
       0xCD,    # Shadow Force
       0xCE     # Sky Drop
    ]
    choices=[]
    for i in 0...4
      found=false
      next if attacker.moves[i].id==0
      found=true if blacklist.include?(attacker.moves[i].function)
      next if found
      choices.push(i) if @battle.pbCanChooseMove?(attacker.index,i,false,true)
    end
    if choices.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    choice=choices[@battle.pbRandom(choices.length)]
    attacker.pbUseMoveSimple(attacker.moves[choice].id,choice,attacker.pbOppositeOpposing)
    return 0
  end
end



################################################################################
# Uses a random move known by any non-user Pokémon in the user's party.
################################################################################
class PokeBattle_Move_0B5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x14,    # Chatter
       0x5C,    # Mimic
       0x5D,    # Sketch
       0x69,    # Transform
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x9C,    # Helping Hand
       0xAA,    # Detect, Protect
       0xAD,    # Feint
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB2,    # Snatch
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xE7,    # Destiny Bond
       0xE8,    # Endure
       0xEC,    # Circle Throw
       0xF1,    # Covet, Thief
       0xF2,    # Switcheroo, Trick
       0xF3,    # Bestow
       0x115,   # Focus Punch
       0x117    # Follow Me, Rage Powder
    ]
    moves=[]
    party=@battle.pbParty(attacker.index) # NOTE: pbParty is common to both allies in multi battles
    for i in 0...party.length
      if i!=attacker.pokemonIndex && party[i] && !party[i].isEgg?
        for j in party[i].moves
          next if isConst?(j.type,PBTypes,:SHADOW)
          next if j.id==0
          found=false
          movedata=PBMoveData.new(j.id)
          found=true if blacklist.include?(movedata.function)
          moves.push(j.id) if !found
        end
      end
    end
    if moves.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    move=moves[@battle.pbRandom(moves.length)]
    attacker.pbUseMoveSimple(move)
    return 0
  end
end



################################################################################
# Uses a random move that exists.
################################################################################
class PokeBattle_Move_0B6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x11,    # Snore
       0x14,    # Chatter
       0x5C,    # Mimic
       0x5D,    # Sketch
       0x69,    # Transform
       0x71,    # Counter
       0x72,    # Mirror Coat
       0x9C,    # Helping Hand
       0xAA,    # Detect, Protect
       0xAB,    # Quick Guard
       0xAC,    # Wide Guard
       0xAD,    # Feint
       0xAE,    # Mirror Move
       0xAF,    # Copycat
       0xB0,    # Me First
       0xB2,    # Snatch
       0xB3,    # Nature Power
       0xB4,    # Sleep Talk
       0xB5,    # Assist
       0xB6,    # Metronome
       0xE7,    # Destiny Bond
       0xE8,    # Endure
       0xF1,    # Covet, Thief
       0xF2,    # Switcheroo, Trick
       0xF3,    # Bestow
       0x115,   # Focus Punch
       0x117,   # Follow Me, Rage Powder
       0x11D,   # After You
       0x11E    # Quash
    ]
    blacklistmoves=[
       :FREEZESHOCK,
       :ICEBURN,
       :RELICSONG,
       :SECRETSWORD,
       :SNARL,
       :TECHNOBLAST,
       :VCREATE
    ]
    i=0; loop do break unless i<1000
      move=@battle.pbRandom(PBMoves.maxValue)+1
      next if isConst?(PBMoveData.new(move).type,PBTypes,:SHADOW)
      found=false
      if blacklist.include?(PBMoveData.new(move).function)
        found=true
      else
        for j in blacklistmoves
          if isConst?(move,PBMoves,j)
            found=true
            break
          end
        end
      end
      if !found
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
        attacker.pbUseMoveSimple(move)
        return 0
      end
      i+=1
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# The target can no longer use the same move twice in a row.
################################################################################
class PokeBattle_Move_0B7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Torment]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Torment]=true
    @battle.pbDisplay(_INTL("{1} was subjected to torment!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Disables all target's moves that the user also knows.
################################################################################
class PokeBattle_Move_0B8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Imprison]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1  
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Imprison]=true
    @battle.pbDisplay(_INTL("{1} sealed the opponent's move(s)!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the last move the target used.
################################################################################
class PokeBattle_Move_0B9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Disable]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in opponent.moves
      if i.id>0 && i.id==opponent.lastMoveUsed && (i.pp>0 || i.totalpp==0)
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.effects[PBEffects::Disable]=4
        opponent.effects[PBEffects::DisableMove]=opponent.lastMoveUsed
        @battle.pbDisplay(_INTL("{1}'s {2} was disabled!",opponent.pbThis,i.name))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# For 4 rounds, disables the target's non-damaging moves.
################################################################################
class PokeBattle_Move_0BA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Taunt]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Taunt]=4
    @battle.pbDisplay(_INTL("{1} fell for the taunt!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, disables the target's healing moves.
################################################################################
class PokeBattle_Move_0BB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::HealBlock]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::HealBlock]=5
    @battle.pbDisplay(_INTL("{1} was prevented from healing!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 4 rounds, the target must use the same move each round.
################################################################################
class PokeBattle_Move_0BC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    blacklist=[
       0x02,    # Struggle
       0x5C,    # Mimic
       0x5D,    # Sketch
       0x69,    # Transform
       0xAE,    # Mirror Move
       0xBC     # Encore
    ]
    if opponent.effects[PBEffects::Encore]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.lastMoveUsed<=0 ||
       blacklist.include?(PBMoveData.new(opponent.lastMoveUsed).function)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    for i in 0...4
      if opponent.lastMoveUsed==opponent.moves[i].id &&
         (opponent.moves[i].pp>0 || opponent.moves[i].totalpp==0)
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        opponent.effects[PBEffects::Encore]=3
        opponent.effects[PBEffects::EncoreIndex]=i
        opponent.effects[PBEffects::EncoreMove]=opponent.moves[i].id
        @battle.pbDisplay(_INTL("{1} received an encore!",opponent.pbThis))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Hits twice.
################################################################################
class PokeBattle_Move_0BD < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end
end



################################################################################
# Hits twice.  May poison the targer on each hit.
################################################################################
class PokeBattle_Move_0BE < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 2
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanPoison?(false)
    opponent.pbPoison(attacker)
    @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Hits 3 times.  Power is multiplied by the hit number.
################################################################################
class PokeBattle_Move_0BF < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return 3
  end

  def pbOnStartUse(attacker)
    @calcbasedmg=@basedamage
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    ret=@calcbasedmg
    @calcbasedmg+=basedmg
    return ret
  end
end



################################################################################
# Hits 2-5 times.
################################################################################
class PokeBattle_Move_0C0 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    hitchances=[2,2,3,3,4,5]
    ret=hitchances[@battle.pbRandom(hitchances.length)]
    ret=5 if attacker.hasWorkingAbility(:SKILLLINK)
    return ret
  end
end



################################################################################
# Hits X times, where X is the number of unfainted status-free Pokémon in the
# user's party (the participants).  Fails if X is 0.
# Base power of each hit depends on the base Attack stat for the species of that
# hit's participant.
################################################################################
class PokeBattle_Move_0C1 < PokeBattle_Move
  def pbIsMultiHit
    return true
  end

  def pbNumHits(attacker)
    return @participants.length
  end

  def pbOnStartUse(attacker)
    party=@battle.pbParty(attacker.index)
    @participants=[]
    for i in 0...party.length
      @participants.push(i) if party[i] && !party[i].isEgg? &&
                               party[i].hp>0 && party[i].status==0
    end
    if @participants.length==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return false
    end
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    party=@battle.pbParty(attacker.index)
    atk=party[@participants[0]].baseStats[1]
    @participants[0]=nil; @participants.compact!
    return 5+(atk/10)
  end
end



################################################################################
# Two turn attack.  Attacks first turn, skips second turn (if successful).
################################################################################
class PokeBattle_Move_0C2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      attacker.effects[PBEffects::HyperBeam]=2
      attacker.currentMove=@id
    end
    return ret
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
################################################################################
class PokeBattle_Move_0C3 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} whipped up a whirlwind!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# Power halved in all weather except sunshine.  In sunshine, takes 1 turn instead.
################################################################################
class PokeBattle_Move_0C4 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if attacker.effects[PBEffects::TwoTurnAttack]==0
      @immediate=true if @battle.pbWeather==PBWeather::SUNNYDAY
    end
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbBaseDamageMultiplier(damagemult,attacker,opponent)
    if @battle.pbWeather!=0 &&
       @battle.pbWeather!=PBWeather::SUNNYDAY
      return (damagemult*0.5).round
    end
    return damagemult
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} took in sunlight!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end




################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May paralyze the target.
################################################################################
class PokeBattle_Move_0C5 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} became cloaked in a freezing light!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
  
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May burn the target.
################################################################################
class PokeBattle_Move_0C6 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} became cloaked in freezing air!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
  
  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.
# May make the target flinch.
################################################################################
class PokeBattle_Move_0C7 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} is glowing!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    if !opponent.hasWorkingAbility(:INNERFOCUS) &&
       opponent.effects[PBEffects::Substitute]==0
      opponent.effects[PBEffects::Flinch]=true
      return true
    end
    return false
  end
end



################################################################################
# Two turn attack.  Ups user's Defence by 1 stage first turn, attacks second turn.
################################################################################
class PokeBattle_Move_0C8 < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} lowered its head!",attacker.pbThis))
      if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
        attacker.pbIncreaseStat(PBStats::DEFENSE,1,false)
      end
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Fly)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0C9 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} flew up high!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dig)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CA < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} burrowed its way under the ground!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Dive)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CB < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} hid underwater!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Bounce)
# May paralyze the target.
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
################################################################################
class PokeBattle_Move_0CC < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} sprang up!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    return super
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Shadow Force)
# Is invulnerable during use.
# If successful, negates target's Detect and Protect this round.
################################################################################
class PokeBattle_Move_0CD < PokeBattle_Move
  def pbTwoTurnAttack(attacker,checking=false)
    @immediate=false
    if !@immediate && attacker.hasWorkingItem(:POWERHERB)
      @immediate=true
      if !checking
        itemname=PBItems.getName(attacker.item)
        attacker.pokemon.itemRecycle=attacker.item
        attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
        attacker.item=0
        @battle.pbDisplay(_INTL("{1} consumed its {2}!",attacker.pbThis,itemname))
      end
    end
    return false if @immediate
    return attacker.effects[PBEffects::TwoTurnAttack]==0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @immediate || attacker.effects[PBEffects::TwoTurnAttack]>0
      pbShowAnimation(@id,attacker,opponent,1,alltargets,showanimation) # Charging anim
      @battle.pbDisplay(_INTL("{1} vanished instantly!",attacker.pbThis))
    end
    return 0 if attacker.effects[PBEffects::TwoTurnAttack]>0
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::ProtectNegation]=true if ret>0
    return ret
  end
end



################################################################################
# Two turn attack.  Skips first turn, attacks second turn.  (Sky Drop)
# (Handled in Battler's pbSuccessCheck):  Is semi-invulnerable during use.
# Target is also semi-invulnerable during use, and can't take any action.
# Doesn't damage airborne Pokémon (but still makes them unable to move during).
################################################################################
class PokeBattle_Move_0CE < PokeBattle_UnimplementedMove
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

# Not implemented yet.
end



################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round.
################################################################################
class PokeBattle_Move_0CF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=4+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=5 if attacker.hasWorkingItem(:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        if isConst?(@id,PBMoves,:BIND)
          @battle.pbDisplay(_INTL("{1} was squeezed by {2}!",opponent.pbThis,attacker.pbThis(true)))
        elsif isConst?(@id,PBMoves,:CLAMP)
          @battle.pbDisplay(_INTL("{1} clamped {2}!",attacker.pbThis,opponent.pbThis(true)))
        elsif isConst?(@id,PBMoves,:FIRESPIN)
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:MAGMASTORM)
          @battle.pbDisplay(_INTL("{1} was trapped by Magma Storm!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:SANDTOMB)
          @battle.pbDisplay(_INTL("{1} was trapped by Sand Tomb!",opponent.pbThis))
        elsif isConst?(@id,PBMoves,:WRAP)
          @battle.pbDisplay(_INTL("{1} was wrapped by {2}!",opponent.pbThis,attacker.pbThis(true)))
        else
          @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
        end
      end
    end
    return ret
  end
end



################################################################################
# Trapping move.  Traps for 4 or 5 rounds.  Trapped Pokémon lose 1/16 of max HP
# at end of each round.
# Power is doubled if target is using Dive.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_0D0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute
      if opponent.effects[PBEffects::MultiTurn]==0
        opponent.effects[PBEffects::MultiTurn]=4+@battle.pbRandom(2)
        opponent.effects[PBEffects::MultiTurn]=5 if attacker.hasWorkingItem(:GRIPCLAW)
        opponent.effects[PBEffects::MultiTurnAttack]=@id
        opponent.effects[PBEffects::MultiTurnUser]=attacker.index
        @battle.pbDisplay(_INTL("{1} was trapped in the vortex!",opponent.pbThis))
      end
    end
    return ret
  end

  def pbModifyDamage(damagemult,attacker,opponent)
    if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCB # Dive
      return (damagemult*2.0).round
    end
    return damagemult
  end
end



################################################################################
# User must use this move for 2 more rounds.  No battlers can sleep.
################################################################################
class PokeBattle_Move_0D1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::Uproar]==0
        attacker.effects[PBEffects::Uproar]=3
        @battle.pbDisplay(_INTL("{1} caused an uproar!",attacker.pbThis))
        attacker.currentMove=@id
      end
    end
    return ret
  end
end



################################################################################
# User must use this move for 1 or 2 more rounds.  At end, user becomes confused.
################################################################################
class PokeBattle_Move_0D2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 &&
       attacker.effects[PBEffects::Outrage]==0 && 
       attacker.status!=PBStatuses::SLEEP  #TODO: Not likely what actually happens, but good enough
      attacker.effects[PBEffects::Outrage]=2+@battle.pbRandom(2)
      attacker.currentMove=@id
    elsif pbTypeModifier(@type,attacker,opponent)==0
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Outrage]=0
    end
    if attacker.effects[PBEffects::Outrage]>0
      attacker.effects[PBEffects::Outrage]-=1
      if attacker.effects[PBEffects::Outrage]==0 && attacker.pbCanConfuseSelf?(false)
        attacker.effects[PBEffects::Confusion]=2+@battle.pbRandom(4)
        @battle.pbCommonAnimation("Confusion",attacker,nil)
        @battle.pbDisplay(_INTL("{1} became confused due to fatigue!",attacker.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User must use this move for 4 more rounds.  Power doubles each round.
# Power is also doubled if user has curled up.
################################################################################
class PokeBattle_Move_0D3 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    shift=(4-attacker.effects[PBEffects::Rollout]) # from 0 through 4, 0 is most powerful
    shift+=1 if attacker.effects[PBEffects::DefenseCurl]
    basedmg=basedmg<<shift
    return basedmg
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    attacker.effects[PBEffects::Rollout]=5 if attacker.effects[PBEffects::Rollout]==0
    attacker.effects[PBEffects::Rollout]-=1
    attacker.currentMove=thismove.id
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage==0 ||
       pbTypeModifier(@type,attacker,opponent)==0 || 
       attacker.status==PBStatuses::SLEEP  #TODO: Not likely what actually happens, but good enough
      # Cancel effect if attack is ineffective
      attacker.effects[PBEffects::Rollout]=0
    end
    return ret
  end
end



################################################################################
# User bides its time this round and next round.  The round after, deals 2x the
# total damage it took while biding to the last battler that damaged it.
################################################################################
class PokeBattle_Move_0D4 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.effects[PBEffects::Bide]==0
      @battle.pbDisplayBrief(_INTL("{1} used\r\n{2}!",attacker.pbThis,name))
      attacker.effects[PBEffects::Bide]=2
      attacker.effects[PBEffects::BideDamage]=0
      attacker.effects[PBEffects::BideTarget]=-1
      attacker.currentMove=@id
      pbShowAnimation(@id,attacker,nil)
      return 1
    else
      attacker.effects[PBEffects::Bide]-=1
      if attacker.effects[PBEffects::Bide]==0
        @battle.pbDisplayBrief(_INTL("{1} unleashed energy!",attacker.pbThis))
        return 0
      else
        @battle.pbDisplayBrief(_INTL("{1} is storing energy!",attacker.pbThis))
        return 2
      end
    end
  end

  def pbAddTarget(targets,attacker)
    if attacker.effects[PBEffects::BideTarget]>=0
      if !attacker.pbAddTarget(targets,@battle.battlers[attacker.effects[PBEffects::BideTarget]])
        attacker.pbRandomTarget(targets)
      end
    end
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::BideDamage]==0 || !opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=pbEffectFixedDamage(attacker.effects[PBEffects::BideDamage]*2,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::BideDamage]=0
    return ret
  end
end



################################################################################
# Heals user by 1/2 of its max HP.
################################################################################
class PokeBattle_Move_0D5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Heals user by 1/2 of its max HP.
# User roosts, and its Flying type is ignored for attacks used against it.
################################################################################
class PokeBattle_Move_0D6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(((attacker.totalhp+1)/2).floor,true)
    attacker.effects[PBEffects::Roost]=true
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Battler in user's position is healed by 1/2 of its max HP, at the end of the
# next round.
################################################################################
class PokeBattle_Move_0D7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Wish]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Wish]=2
    attacker.effects[PBEffects::WishAmount]=((attacker.totalhp+1)/2).floor
    attacker.effects[PBEffects::WishMaker]=attacker.pokemonIndex
    return 0
  end
end



################################################################################
# Heals user by an amount depending on the weather.
################################################################################
class PokeBattle_Move_0D8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    hpgain=0
    if @battle.pbWeather==PBWeather::SUNNYDAY
      hpgain=(attacker.totalhp*2/3).floor
    elsif @battle.pbWeather!=0
      hpgain=(attacker.totalhp/4).floor
    else
      hpgain=(attacker.totalhp/2).floor
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    return 0
  end
end



################################################################################
# Heals user to full HP.  User falls asleep for 2 more rounds.
################################################################################
class PokeBattle_Move_0D9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !attacker.pbCanSleep?(true,true,true)
      return -1
    end
    if attacker.hp==attacker.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbSleepSelf(3)
    @battle.pbDisplay(_INTL("{1} slept and became healthy!",attacker.pbThis))
    hp=attacker.pbRecoverHP(attacker.totalhp-attacker.hp,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis)) if hp>0
    return 0
  end
end



################################################################################
# Rings the user.  Ringed Pokémon gain 1/16 of max HP at the end of each round.
################################################################################
class PokeBattle_Move_0DA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::AquaRing]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::AquaRing]=true
    @battle.pbDisplay(_INTL("{1} surrounded itself with a veil of water!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Ingrains the user.  Ingrained Pokémon gain 1/16 of max HP at the end of each
# round, and cannot flee or switch out.
################################################################################
class PokeBattle_Move_0DB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Ingrain]=true
    @battle.pbDisplay(_INTL("{1} planted its roots!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Seeds the target.  Seeded Pokémon lose 1/8 of max HP at the end of each
# round, and the Pokémon in the user's position gains the same amount.
################################################################################
class PokeBattle_Move_0DC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::LeechSeed]>=0 ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} evaded the attack!",opponent.pbThis))
      return -1
    end
    if opponent.pbHasType?(:GRASS)
      @battle.pbDisplay(_INTL("It doesn't affect {1}...",opponent.pbThis(true)))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::LeechSeed]=attacker.index
    @battle.pbDisplay(_INTL("{1} was seeded!",opponent.pbThis))
    return 0
  end
end



################################################################################
# User gains half the HP it inflicts as damage.
################################################################################
class PokeBattle_Move_0DD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=((opponent.damagestate.hplost+1)/2).floor
      if opponent.hasWorkingAbility(:LIQUIDOOZE)
        attacker.pbReduceHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} sucked up the liquid ooze!",attacker.pbThis))
      elsif attacker.effects[PBEffects::HealBlock]==0
        hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
        attacker.pbRecoverHP(hpgain,true)
        @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
      end
    end
    return ret
  end
end



################################################################################
# User gains half the HP it inflicts as damage.
# (Handled in Battler's pbSuccessCheck): Fails if target is not asleep.
################################################################################
class PokeBattle_Move_0DE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      hpgain=((opponent.damagestate.hplost+1)/2).floor
      hpgain=(hpgain*1.3).floor if attacker.hasWorkingItem(:BIGROOT)
      attacker.pbRecoverHP(hpgain,true) if attacker.effects[PBEffects::HealBlock]==0
      @battle.pbDisplay(_INTL("{1} had its energy drained!",opponent.pbThis))
    end
    return ret
  end
end



################################################################################
# Heals target by 1/2 of its max HP.
################################################################################
class PokeBattle_Move_0DF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))  
      return -1
    end
    if opponent.hp==opponent.totalhp
      @battle.pbDisplay(_INTL("{1}'s HP is full!",opponent.pbThis))  
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    hpgain=((opponent.totalhp+1)/2).floor
    opponent.pbRecoverHP(hpgain,true)
    @battle.pbDisplay(_INTL("{1}'s HP was restored.",opponent.pbThis))  
    return 0
  end
end



################################################################################
# User faints.
################################################################################
class PokeBattle_Move_0E0 < PokeBattle_Move
  def pbOnStartUse(attacker)
    bearer=@battle.pbCheckGlobalAbility(:DAMP)
    if bearer
      @battle.pbDisplay(_INTL("{1}'s {2} prevents {3} from using {4}!",
         bearer.pbThis,PBAbilities.getName(bearer.ability),attacker.pbThis(true),@name))
      return false
    end
    @battle.pbAnimation(@id,attacker,nil)
    pbShowAnimation(@id,attacker,nil)
    attacker.pbReduceHP(attacker.hp)
    return true
  end

  def pbShowAnimation(id,attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    return
  end
end



################################################################################
# Inflicts fixed damage equal to user's current HP.
# User faints (if successful).
################################################################################
class PokeBattle_Move_0E1 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Decreases the target's Attack and Special Attack by 2 stages each.
# User faints (even if effect does nothing).
################################################################################
class PokeBattle_Move_0E2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=-1; prevented=false
    if opponent.effects[PBEffects::Protect] &&
       !opponent.effects[PBEffects::ProtectNegation]
      @battle.pbDisplay(_INTL("{1} protected itself!",opponent.pbThis))
      @battle.successStates[attacker.index].protected=true
      prevented=true
    end
    if !prevented && opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it had no effect!"))
      prevented=true
    end
    if !prevented && opponent.pbOwnSide.effects[PBEffects::Mist]>0
      @battle.pbDisplay(_INTL("{1} is protected by Mist!",opponent.pbThis))
      prevented=true
    end
    if !prevented && (opponent.hasWorkingAbility(:CLEARBODY) ||
       opponent.hasWorkingAbility(:WHITESMOKE))
      @battle.pbDisplay(_INTL("{1}'s {2} prevents stat loss!",opponent.pbThis,
         PBAbilities.getName(opponent.ability)))
      prevented=true
    end
    if !prevented && opponent.pbTooLow?(PBStats::ATTACK) &&
       opponent.pbTooLow?(PBStats::SPATK)
      @battle.pbDisplay(_INTL("{1}'s stats won't go any lower!",opponent.pbThis))
      prevented=true
    end
    if !prevented
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      showanim=true
      if opponent.pbReduceStat(PBStats::ATTACK,2,false,showanim)
        ret=0; showanim=false
      end
      if opponent.pbReduceStat(PBStats::SPATK,2,false,showanim)
        ret=0; showanim=false
      end
    end
    attacker.pbReduceHP(attacker.hp) # User still faints even if protected by above effects
    return ret
  end
end



################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP and
# status).  Fails if user won't be replaced.
################################################################################
class PokeBattle_Move_0E3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::HealingWish]=true
    return 0
  end
end



################################################################################
# User faints.  The Pokémon that replaces the user is fully healed (HP, PP and
# status).  Fails if user won't be replaced.
################################################################################
class PokeBattle_Move_0E4 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.pbReduceHP(attacker.hp)
    attacker.effects[PBEffects::LunarDance]=true
    return 0
  end
end



################################################################################
# All current battlers will perish after 3 more rounds.
################################################################################
class PokeBattle_Move_0E5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=true
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0 &&
         !@battle.battlers[i].hasWorkingAbility(:SOUNDPROOF)
        failed=false; break
      end   
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    @battle.pbDisplay(_INTL("All Pokémon hearing the song will faint in three turns!"))
    for i in 0...4
      if @battle.battlers[i].effects[PBEffects::PerishSong]==0
        if @battle.battlers[i].hasWorkingAbility(:SOUNDPROOF)
          @battle.pbDisplay(_INTL("{1}'s {2} blocks {3}!",@battle.battlers[i].pbThis,
             PBAbilities.getName(@battle.battlers[i].ability),@name))
        else
          @battle.battlers[i].effects[PBEffects::PerishSong]=4
          @battle.battlers[i].effects[PBEffects::PerishSongUser]=attacker.index
        end
      end
    end
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the attack that caused it loses all PP.
################################################################################
class PokeBattle_Move_0E6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Grudge]=true
    @battle.pbDisplay(_INTL("{1} wants its target to bear a grudge!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If user is KO'd before it next moves, the battler that caused it also faints.
################################################################################
class PokeBattle_Move_0E7 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::DestinyBond]=true
    @battle.pbDisplay(_INTL("{1} is trying to take its foe down with it!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If user would be KO'd this round, it survives with 1HP instead.
################################################################################
class PokeBattle_Move_0E8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    # TODO: Fails if attack strikes last
    ratesharers=[
       0xAA,   # Detect, Protect
       0xAB,   # Quick Guard
       0xAC,   # Wide Guard
       0xE8    # Endure
    ]
    if !ratesharers.include?(PBMoveData.new(attacker.lastMoveUsed).function)
      attacker.effects[PBEffects::ProtectRate]=1
    end
    if @battle.pbRandom(65536)>(65536/attacker.effects[PBEffects::ProtectRate]).floor
      attacker.effects[PBEffects::ProtectRate]=1
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Endure]=true
    attacker.effects[PBEffects::ProtectRate]*=2
    @battle.pbDisplay(_INTL("{1} braced itself!",attacker.pbThis))
    return 0
  end
end



################################################################################
# If target would be KO'd by this attack, it survives with 1HP instead.
################################################################################
class PokeBattle_Move_0E9 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# User flees from battle.  Fails in trainer battles.
################################################################################
class PokeBattle_Move_0EA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.opponent
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    elsif @battle.pbCanRun?(attacker.index)
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.pbDisplay(_INTL("{1} fled from battle!",attacker.pbThis))
      @battle.decision=3
      return 0
    else
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
  end
end



################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For status moves.
################################################################################
class PokeBattle_Move_0EB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.hasWorkingAbility(:SUCTIONCUPS)
      @battle.pbDisplay(_INTL("{1} anchored itself with {2}!",opponent.pbThis,PBAbilities.getName(opponent.ability)))  
      return -1
    end
    if opponent.effects[PBEffects::Ingrain]
      @battle.pbDisplay(_INTL("{1} anchored itself with its roots!",opponent.pbThis))  
      return -1
    end
    if !@battle.opponent
      if opponent.level>=attacker.level
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.decision=3 # Set decision to escaped
      return 0
    else
      choices=[]
      party=@battle.pbParty(opponent.index)
      for i in 0...party.length
        choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
      end
      if choices.length==0
        @battle.pbDisplay(_INTL("But it failed!"))
        return -1
      end
      newpoke=choices[@battle.pbRandom(choices.length)]
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      opponent.pbResetForm
      @battle.pbReplace(opponent.index,newpoke,false)
      @battle.pbDisplay(_INTL("{1} was dragged out!",opponent.pbThis))
      @battle.pbOnActiveOne(opponent)
      opponent.pbAbilitiesOnSwitchIn(true)
      return 0
    end
  end
end



################################################################################
# Target flees from battle.  In trainer battles, target switches out instead.
# Fails if target is a higher level than the user.  For damaging moves.
################################################################################
class PokeBattle_Move_0EC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && !opponent.isFainted? &&
       opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute && 
       !opponent.hasWorkingAbility(:SUCTIONCUPS) &&
       !opponent.effects[PBEffects::Ingrain]
      if !@battle.opponent
        if opponent.level<attacker.level
          @battle.decision=3 # Set decision to escaped
        end
      else
        choices=[]
        party=@battle.pbParty(opponent.index)
        for i in 0..party.length-1
          choices[choices.length]=i if @battle.pbCanSwitchLax?(opponent.index,i,false)
        end
        if choices.length>0
          newpoke=choices[@battle.pbRandom(choices.length)]
          opponent.pbResetForm
          @battle.pbReplace(opponent.index,newpoke,false)
          @battle.pbDisplay(_INTL("{1} was dragged out!",opponent.pbThis))
          @battle.pbOnActiveOne(opponent)
          opponent.pbAbilitiesOnSwitchIn(true)
        end
      end
    end
    return ret
  end
end



################################################################################
# User switches out.  Various effects affecting the user are passed to the
# replacement.
################################################################################
class PokeBattle_Move_0ED < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.pbCanChooseNonActive?(attacker.index)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    newpoke=0
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
    @battle.pbMessagesOnReplace(attacker.index,newpoke)
    attacker.pbResetForm
    @battle.pbReplace(attacker.index,newpoke,true)
    @battle.pbOnActiveOne(attacker)
    attacker.pbAbilitiesOnSwitchIn(true)
    return 0
  end
end



################################################################################
# After inflicting damage, user switches out.  Ignores trapping moves.
################################################################################
class PokeBattle_Move_0EE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && @battle.pbCanChooseNonActive?(attacker.index) &&
       !@battle.pbAllFainted?(@battle.pbParty(opponent.index))
      # TODO: Pursuit should go here, and negate this effect if it KO's attacker
      @battle.pbDisplay(_INTL("{1} went back to {2}!",attacker.pbThis,@battle.pbGetOwner(attacker.index).name))
      newpoke=0
      newpoke=@battle.pbSwitchInBetween(attacker.index,true,false)
      @battle.pbMessagesOnReplace(attacker.index,newpoke)
      attacker.pbResetForm
      @battle.pbReplace(attacker.index,newpoke,true)
      @battle.pbOnActiveOne(attacker)
      attacker.pbAbilitiesOnSwitchIn(true)
    end
    return ret
  end
end



################################################################################
# Target can no longer switch out or flee, as long as the user remains active.
################################################################################
class PokeBattle_Move_0EF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::MeanLook]>=0 ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::MeanLook]=attacker.index
    @battle.pbDisplay(_INTL("{1} can't escape now!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Target drops its item.  It regains the item at the end of the battle.
################################################################################
class PokeBattle_Move_0F0 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !opponent.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.item!=0
      if opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item)
        itemname=PBItems.getName(opponent.item)
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        @battle.pbDisplay(_INTL("{1} knocked off {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
    return ret
  end
end



################################################################################
# User steals the target's item, if the user has none itself.
# Items stolen from wild Pokémon are kept after the battle.
################################################################################
class PokeBattle_Move_0F1 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && opponent.item!=0
      if opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      elsif !@battle.pbIsUnlosableItem(opponent,opponent.item) &&
            !@battle.pbIsUnlosableItem(attacker,opponent.item) &&
            attacker.item==0 &&
            (@battle.opponent || !@battle.pbIsOpposing?(attacker.index))
        itemname=PBItems.getName(opponent.item)
        attacker.item=opponent.item
        opponent.item=0
        opponent.effects[PBEffects::ChoiceBand]=-1
        if !@battle.opponent && # In a wild battle
           attacker.pokemon.itemInitial==0 &&
           opponent.pokemon.itemInitial==attacker.item
          attacker.pokemon.itemInitial=attacker.item
          opponent.pokemon.itemInitial=0
        end
        @battle.pbDisplay(_INTL("{1} stole {2}'s {3}!",attacker.pbThis,opponent.pbThis(true),itemname))
      end
    end
    return ret
  end
end



################################################################################
# User and target swap items.  They remain swapped after the battle.
################################################################################
class PokeBattle_Move_0F2 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if (attacker.item==0 && opponent.item==0) ||
       (!@battle.opponent && @battle.pbIsOpposing?(attacker.index))
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(opponent,opponent.item) ||
       @battle.pbIsUnlosableItem(attacker,opponent.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item) ||
       @battle.pbIsUnlosableItem(attacker,attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if opponent.hasWorkingAbility(:STICKYHOLD)
      abilityname=PBAbilities.getName(opponent.ability)
      @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,name))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    oldattitem=attacker.item
    oldoppitem=opponent.item
    oldattitemname=PBItems.getName(oldattitem)
    oldoppitemname=PBItems.getName(oldoppitem)
    tmpitem=attacker.item
    attacker.item=opponent.item
    opponent.item=tmpitem
    if !@battle.opponent && # In a wild battle
       attacker.pokemon.itemInitial==oldattitem &&
       opponent.pokemon.itemInitial==oldoppitem
      attacker.pokemon.itemInitial=oldoppitem
      opponent.pokemon.itemInitial=oldattitem
    end
    @battle.pbDisplay(_INTL("{1} switched items with its opponent!",attacker.pbThis))
    if oldoppitem>0 && oldattitem>0
      @battle.pbDisplayPaused(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname))
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname))
    else
      @battle.pbDisplay(_INTL("{1} obtained {2}.",attacker.pbThis,oldoppitemname)) if oldoppitem>0
      @battle.pbDisplay(_INTL("{1} obtained {2}.",opponent.pbThis,oldattitemname)) if oldattitem>0
    end
    if oldattitem!=oldoppitem # TODO: Not exactly correct
      attacker.effects[PBEffects::ChoiceBand]=-1
    end
    opponent.effects[PBEffects::ChoiceBand]=-1
    return 0
  end
end



################################################################################
# User gives its item to the target.  The item remains given after the battle.
################################################################################
class PokeBattle_Move_0F3 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if attacker.item==0 || opponent.item!=0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    if @battle.pbIsUnlosableItem(attacker,attacker.item) ||
       @battle.pbIsUnlosableItem(opponent,attacker.item)
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    itemname=PBItems.getName(attacker.item)
    opponent.item=attacker.item
    attacker.item=0
    attacker.effects[PBEffects::ChoiceBand]=-1
    if !@battle.opponent && # In a wild battle
       opponent.pokemon.itemInitial==0 &&
       attacker.pokemon.itemInitial==opponent.item
      opponent.pokemon.itemInitial=opponent.item
      attacker.pokemon.itemInitial=0
    end
    @battle.pbDisplay(_INTL("{1} received {2} from {3}!",opponent.pbThis,itemname,attacker.pbThis(true)))
    return 0
  end
end



################################################################################
# User consumes target's berry and gains its effect.
################################################################################
class PokeBattle_Move_0F4 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && pbIsBerry?(opponent.item)
      if opponent.hasWorkingAbility(:STICKYHOLD)
        abilityname=PBAbilities.getName(opponent.ability)
        @battle.pbDisplay(_INTL("{1}'s {2} made {3} ineffective!",opponent.pbThis,abilityname,@name))
      else
        item=opponent.item
        itemname=PBItems.getName(item)
        opponent.item=0
        opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==item
        @battle.pbDisplay(_INTL("{1} stole and ate its target's {2}!",attacker.pbThis,itemname))
        if !attacker.hasWorkingAbility(:KLUTZ) &&
           attacker.effects[PBEffects::Embargo]==0
          # Get berry's effect here
        end
      end
    end
    return ret
  end
end



################################################################################
# Target's berry is destroyed.
################################################################################
class PokeBattle_Move_0F5 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0 &&
       !opponent.damagestate.substitute && pbIsBerry?(opponent.item)
      item=opponent.item
      itemname=PBItems.getName(item)
      opponent.item=0
      opponent.pokemon.itemInitial=0 if opponent.pokemon.itemInitial==item
      @battle.pbDisplay(_INTL("{1}'s {2} was incinerated!",opponent.pbThis,itemname))
    end
    return ret
  end
end



################################################################################
# User recovers the last item it held and consumed.
################################################################################
class PokeBattle_Move_0F6 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pokemon.itemRecycle==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    item=attacker.pokemon.itemRecycle
    itemname=PBItems.getName(item)
    attacker.item=item
    attacker.pokemon.itemInitial=item if attacker.pokemon.itemInitial==0
    attacker.pokemon.itemRecycle=0
    @battle.pbDisplay(_INTL("{1} found one {2}!",attacker.pbThis,itemname))
    return 0
  end
end



################################################################################
# User flings its item at the target.  Power and effect depend on the item.
################################################################################
class PokeBattle_Move_0F7 < PokeBattle_Move
  def flingarray
    return {
       130 => [:IRONBALL],
       100 => [:ARMORFOSSIL,:CLAWFOSSIL,:COVERFOSSIL,:DOMEFOSSIL,:HARDSTONE,
               :HELIXFOSSIL,:OLDAMBER,:PLUMEFOSSIL,:RAREBONE,:ROOTFOSSIL,
               :SKULLFOSSIL],
        90 => [:DEEPSEATOOTH,:DRACOPLATE,:DREADPLATE,:EARTHPLATE,:FISTPLATE,
               :FLAMEPLATE,:GRIPCLAW,:ICICLEPLATE,:INSECTPLATE,:IRONPLATE,
               :MEADOWPLATE,:MINDPLATE,:SKYPLATE,:SPLASHPLATE,:SPOOKYPLATE,
               :STONEPLATE,:THICKCLUB,:TOXICPLATE,:ZAPPLATE],
        80 => [:DAWNSTONE,:DUSKSTONE,:ELECTIRIZER,:MAGMARIZER,:ODDKEYSTONE,
               :OVALSTONE,:PROTECTOR,:QUICKCLAW,:RAZORCLAW,:SHINYSTONE,
               :STICKYBARB],
        70 => [:BURNDRIVE,:CHILLDRIVE,:DOUSEDRIVE,:DRAGONFANG,:POISONBARB,
               :POWERANKLET,:POWERBAND,:POWERBELT,:POWERBRACER,:POWERLENS,
               :POWERWEIGHT,:SHOCKDRIVE],
        60 => [:ADAMANTORB,:DAMPROCK,:HEATROCK,:LUSTROUSORB,:MACHOBRACE,
               :ROCKYHELMET,:STICK],
        50 => [:DUBIOUSDISC,:SHARPBEAK],
        40 => [:EVIOLITE,:ICYROCK,:LUCKYPUNCH],
        30 => [:ABILITYURGE,:ABSORBBULB,:AMULETCOIN,:ANTIDOTE,:AWAKENING,
               :BALMMUSHROOM,:BERRYJUICE,:BIGMUSHROOM,:BIGNUGGET,:BIGPEARL,
               :BINDINGBAND,:BLACKBELT,:BLACKFLUTE,:BLACKGLASSES,:BLACKSLUDGE,
               :BLUEFLUTE,:BLUESHARD,:BURNHEAL,:CALCIUM,:CARBOS,
               :CASTELIACONE,:CELLBATTERY,:CHARCOAL,:CLEANSETAG,:COMETSHARD,
               :DAMPMULCH,:DEEPSEASCALE,:DIREHIT,:DIREHIT2,:DIREHIT3,
               :DRAGONSCALE,:EJECTBUTTON,:ELIXIR,:ENERGYPOWDER,:ENERGYROOT,
               :ESCAPEROPE,:ETHER,:EVERSTONE,:EXPSHARE,:FIRESTONE,
               :FLAMEORB,:FLOATSTONE,:FLUFFYTAIL,:FRESHWATER,:FULLHEAL,
               :FULLRESTORE,:GOOEYMULCH,:GREENSHARD,:GROWTHMULCH,:GUARDSPEC,
               :HEALPOWDER,:HEARTSCALE,:HONEY,:HPUP,:HYPERPOTION,
               :ICEHEAL,:IRON,:ITEMDROP,:ITEMURGE,:KINGSROCK,
               :LAVACOOKIE,:LEAFSTONE,:LEMONADE,:LIFEORB,:LIGHTBALL,
               :LIGHTCLAY,:LUCKYEGG,:MAGNET,:MAXELIXIR,:MAXETHER,
               :MAXPOTION,:MAXREPEL,:MAXREVIVE,:METALCOAT,:METRONOME,
               :MIRACLESEED,:MOOMOOMILK,:MOONSTONE,:MYSTICWATER,:NEVERMELTICE,
               :NUGGET,:OLDGATEAU,:PARLYZHEAL,:PEARL,:PEARLSTRING,
               :POKEDOLL,:POKETOY,:POTION,:PPMAX,:PPUP,
               :PRISMSCALE,:PROTEIN,:RAGECANDYBAR,:RARECANDY,:RAZORFANG,
               :REDFLUTE,:REDSHARD,:RELICBAND,:RELICCOPPER,:RELICCROWN,
               :RELICGOLD,:RELICSILVER,:RELICSTATUE,:RELICVASE,:REPEL,
               :RESETURGE,:REVIVALHERB,:REVIVE,:SACREDASH,:SCOPELENS,
               :SHELLBELL,:SHOALSALT,:SHOALSHELL,:SMOKEBALL,:SODAPOP,
               :SOULDEW,:SPELLTAG,:STABLEMULCH,:STARDUST,:STARPIECE,
               :SUNSTONE,:SUPERPOTION,:SUPERREPEL,:SWEETHEART,:THUNDERSTONE,
               :TINYMUSHROOM,:TOXICORB,:TWISTEDSPOON,:UPGRADE,:WATERSTONE,
               :WHITEFLUTE,:XACCURACY,:XACCURACY2,:XACCURACY3,:XACCURACY6,
               :XATTACK,:XATTACK2,:XATTACK3,:XATTACK6,:XDEFEND,
               :XDEFEND2,:XDEFEND3,:XDEFEND6,:XSPDEF,:XSPDEF2,
               :XSPDEF3,:XSPDEF6,:XSPECIAL,:XSPECIAL2,:XSPECIAL3,
               :XSPECIAL6,:XSPEED,:XSPEED2,:XSPEED3,:XSPEED6,
               :YELLOWFLUTE,:YELLOWSHARD,:ZINC],
        20 => [:CLEVERWING,:GENIUSWING,:HEALTHWING,:MUSCLEWING,:PRETTYWING,
               :RESISTWING,:SWIFTWING],
        10 => [:AIRBALLOON,:BIGROOT,:BLUESCARF,:BRIGHTPOWDER,:CHOICEBAND,
               :CHOICESCARF,:CHOICESPECS,:DESTINYKNOT,:EXPERTBELT,:FOCUSBAND,
               :FOCUSSASH,:FULLINCENSE,:GREENSCARF,:LAGGINGTAIL,:LAXINCENSE,
               :LEFTOVERS,:LUCKINCENSE,:MENTALHERB,:METALPOWDER,:MUSCLEBAND,
               :ODDINCENSE,:PINKSCARF,:POWERHERB,:PUREINCENSE,:QUICKPOWDER,
               :REAPERCLOTH,:REDCARD,:REDSCARF,:RINGTARGET,:ROCKINCENSE,
               :ROSEINCENSE,:SEAINCENSE,:SHEDSHELL,:SILKSCARF,:SILVERPOWDER,
               :SMOOTHROCK,:SOFTSAND,:SOOTHEBELL,:WAVEINCENSE,:WHITEHERB,
               :WIDELENS,:WISEGLASSES,:YELLOWSCARF,:ZOOMLENS]
    }
  end

  def pbMoveFailed(attacker,opponent)
    return true if attacker.item==0 ||
                   @battle.pbIsUnlosableItem(attacker,attacker.item) ||
                   pbIsPokeBall?(attacker.item) ||
                   attacker.hasWorkingAbility(:KLUTZ) ||
                   attacker.effects[PBEffects::Embargo]>0
    for i in flingarray.keys
      data=flingarray[i]
      if data
        for j in data
          return false if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return false if pbIsBerry?(attacker.item)
    return true
  end

  def pbBaseDamage(basedmg,attacker,opponent)
    for i in flingarray.keys
      data=flingarray[i]
      if data
        for j in data
          return i if isConst?(attacker.item,PBItems,j)
        end
      end
    end
    return 10 if pbIsBerry?(attacker.item)
    return 1
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.item==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return 0
    end
    if !opponent.effects[PBEffects::Protect]
      @battle.pbDisplay(_INTL("{1} flung its {2}!",attacker.pbThis,PBItems.getName(attacker.item)))
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.hasWorkingAbility(:SHIELDDUST)
#      if $ItemData[@item][ITEMPOCKET]==4
#        pbSpecialBerryUse(opponent,attacker,false,true)
#      end
      if attacker.hasWorkingItem(:FLAMEORB)
        if opponent.pbCanBurn?(false)
          opponent.pbBurn(attacker)
          @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:KINGSROCK) ||
            attacker.hasWorkingItem(:RAZORFANG)
        if !opponent.hasWorkingAbility(:INNERFOCUS) &&
           opponent.effects[PBEffects::Substitute]==0
          opponent.effects[PBEffects::Flinch]=true
        end
      elsif attacker.hasWorkingItem(:LIGHTBALL)
         if opponent.pbCanParalyze?(false)
          opponent.pbParalyze(attacker)
          @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:MENTALHERB)
        if opponent.effects[PBEffects::Attract]>=0
          opponent.effects[PBEffects::Attract]=-1
          @battle.pbDisplay(_INTL("{1}'s {2} cured {3}'s love problem!",
             attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      elsif attacker.hasWorkingItem(:POISONBARB)
        if opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker)
          @battle.pbDisplay(_INTL("{1} was poisoned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:TOXICORB)
        if opponent.pbCanPoison?(false)
          opponent.pbPoison(attacker,true)
          @battle.pbDisplay(_INTL("{1} was badly poisoned!",opponent.pbThis))
        end
      elsif attacker.hasWorkingItem(:WHITEHERB)
        while true
          reducedstats=false
          for i in [PBStats::ATTACK,PBStats::DEFENSE,
                    PBStats::SPEED,PBStats::SPATK,PBStats::SPDEF,
                    PBStats::EVASION,PBStats::ACCURACY]
            if opponent.stages[i]<0
              opponent.stages[i]=0; reducedstats=true
            end
          end
          break if !reducedstats
          @battle.pbDisplay(_INTL("{1}'s {2} restored {3}'s status!",
             attacker.pbThis,PBItems.getName(attacker.item),opponent.pbThis(true)))
        end
      end
    end
    attacker.pokemon.itemRecycle=attacker.item
    attacker.pokemon.itemInitial=0 if attacker.pokemon.itemInitial==attacker.item
    attacker.item=0
    return ret
  end
end



################################################################################
# For 5 rounds, the target cannnot use its held item, its held item has no
# effect, and no items can be used on it.
################################################################################
class PokeBattle_Move_0F8 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Embargo]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Embargo]=5
    @battle.pbDisplay(_INTL("{1} can't use items anymore!",opponent.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, all held items cannot be used in any way and have no effect.
# Held items can still change hands, but can't be thrown.
################################################################################
class PokeBattle_Move_0F9 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::MagicRoom]>0
      @battle.field.effects[PBEffects::MagicRoom]=0
      @battle.pbDisplay(_INTL("The area returned to normal!"))
    else
      pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
      @battle.field.effects[PBEffects::MagicRoom]=5
      @battle.pbDisplay(_INTL("It created a bizarre area in which Pokémon's held items lose their effects!"))
    end
    return 0
  end
end



################################################################################
# User takes recoil damage equal to 1/4 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FA < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !attacker.hasWorkingAbility(:ROCKHEAD)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+2)/4).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FB < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !attacker.hasWorkingAbility(:ROCKHEAD)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/2 of the damage this move dealt.
################################################################################
class PokeBattle_Move_0FC < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !attacker.hasWorkingAbility(:ROCKHEAD)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/2).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May paralyze the target.
################################################################################
class PokeBattle_Move_0FD < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !attacker.hasWorkingAbility(:ROCKHEAD)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanParalyze?(false)
    opponent.pbParalyze(attacker)
    @battle.pbDisplay(_INTL("{1} was paralyzed!  It may be unable to move!",opponent.pbThis))
    return true
  end
end



################################################################################
# User takes recoil damage equal to 1/3 of the damage this move dealt.
# May burn the target.
################################################################################
class PokeBattle_Move_0FE < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !attacker.hasWorkingAbility(:ROCKHEAD)
      attacker.pbReduceHP([1,((opponent.damagestate.hplost+1)/3).floor].max)
      @battle.pbDisplay(_INTL("{1} is damaged by the recoil!",attacker.pbThis))
    end
    return ret
  end

  def pbAdditionalEffect(attacker,opponent)
    return false if !opponent.pbCanBurn?(false)
    opponent.pbBurn(attacker)
    @battle.pbDisplay(_INTL("{1} was burned!",opponent.pbThis))
    return true
  end
end



################################################################################
# Starts sunny weather.
################################################################################
class PokeBattle_Move_0FF < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.weather==PBWeather::SUNNYDAY
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::SUNNYDAY
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:HEATROCK)
    @battle.pbCommonAnimation("Sunny",nil,nil)
    @battle.pbDisplay(_INTL("The sunlight turned harsh!"))
    return 0
  end
end



################################################################################
# Starts rainy weather.
################################################################################
class PokeBattle_Move_100 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.weather==PBWeather::RAINDANCE
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::RAINDANCE
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:DAMPROCK)
    @battle.pbCommonAnimation("Rain",nil,nil)
    @battle.pbDisplay(_INTL("It started to rain!"))
    return 0
  end
end



################################################################################
# Starts sandstorm weather.
################################################################################
class PokeBattle_Move_101 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.weather==PBWeather::SANDSTORM
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::SANDSTORM
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:SMOOTHROCK)
    @battle.pbCommonAnimation("Sandstorm",nil,nil)
    @battle.pbDisplay(_INTL("A sandstorm brewed!"))
    return 0
  end
end



################################################################################
# Starts hail weather.
################################################################################
class PokeBattle_Move_102 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.weather==PBWeather::HAIL
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.weather=PBWeather::HAIL
    @battle.weatherduration=5
    @battle.weatherduration=8 if attacker.hasWorkingItem(:ICYROCK)
    @battle.pbCommonAnimation("Hail",nil,nil)
    @battle.pbDisplay(_INTL("It started to hail!"))
    return 0
  end
end



################################################################################
# Entry hazard.  Lays spikes on the opposing side (max. 3 layers).
################################################################################
class PokeBattle_Move_103 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::Spikes]>=3
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::Spikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Spikes were scattered all around the feet of the foe's team!"))
    else
      @battle.pbDisplay(_INTL("Spikes were scattered all around the feet of your team!"))
    end
    return 0
  end
end



################################################################################
# Entry hazard.  Lays poison spikes on the opposing side (max. 2 layers).
################################################################################
class PokeBattle_Move_104 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]>=2
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::ToxicSpikes]+=1
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around the foe's team's feet!"))
    else
      @battle.pbDisplay(_INTL("Poison spikes were scattered all around your team's feet!"))
    end
    return 0
  end
end



################################################################################
# Entry hazard.  Lays stealth rocks on the opposing side.
################################################################################
class PokeBattle_Move_105 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.pbOpposingSide.effects[PBEffects::StealthRock]
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.pbOpposingSide.effects[PBEffects::StealthRock]=true
    if !@battle.pbIsOpposing?(attacker.index)
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your foe's team!"))
    else
      @battle.pbDisplay(_INTL("Pointed stones float in the air around your team!"))
    end
    return 0
  end
end



################################################################################
# If used after ally's Fire Pledge, makes a sea of fire on the opposing side.
################################################################################
class PokeBattle_Move_106 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamage
end



################################################################################
# If used after ally's Water Pledge, makes a rainbow appear on the user's side.
################################################################################
class PokeBattle_Move_107 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamage
end



################################################################################
# If used after ally's Grass Pledge, makes a swamp appear on the opposing side.
################################################################################
class PokeBattle_Move_108 < PokeBattle_UnimplementedMove
# Not implemented yet.
# Uses pbBaseDamage
end



################################################################################
# Scatters coins that the player picks up after winning the battle.
################################################################################
class PokeBattle_Move_109 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0
      if @battle.pbOwnedByPlayer?(attacker.index)
        @battle.extramoney+=5*attacker.level
        @battle.extramoney=MAXMONEY if @battle.extramoney>MAXMONEY
      end
      @battle.pbDisplay(_INTL("Coins were scattered everywhere!"))
    end
    return ret
  end
end



################################################################################
# Ends the opposing side's Light Screen and Reflect.
################################################################################
class PokeBattle_Move_10A < PokeBattle_Move
  def pbCalcDamage(attacker,opponent)
    return super(attacker,opponent,PokeBattle_Move::NOREFLECT)
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if attacker.pbOpposingSide.effects[PBEffects::Reflect]>0
      attacker.pbOpposingSide.effects[PBEffects::Reflect]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Reflect wore off!"))
      else
        @battle.pbDisplayPaused(_INTL("Your team's Reflect wore off!"))
      end
    end
    if attacker.pbOpposingSide.effects[PBEffects::LightScreen]>0
      attacker.pbOpposingSide.effects[PBEffects::LightScreen]=0
      if !@battle.pbIsOpposing?(attacker.index)
        @battle.pbDisplay(_INTL("The opposing team's Light Screen wore off!"))
      else
        @battle.pbDisplay(_INTL("Your team's Light Screen wore off!"))
      end
    end
    return ret
  end
end



################################################################################
# If attack misses, user takes crash damage of 1/2 of max HP.
################################################################################
class PokeBattle_Move_10B < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end
end



################################################################################
# User turns 1/4 of max HP into a substitute.
################################################################################
class PokeBattle_Move_10C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("{1} already has a substitute!",attacker.pbThis))
      return -1
    end
    sublife=[(attacker.totalhp/4).floor,1].max
    if attacker.hp<=sublife
      @battle.pbDisplay(_INTL("It was too weak to make a substitute!"))
      return -1  
    end
    attacker.pbReduceHP(sublife)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MultiTurn]=0
    attacker.effects[PBEffects::MultiTurnAttack]=0
    attacker.effects[PBEffects::Substitute]=sublife
    @battle.pbDisplay(_INTL("{1} put in a substitute!",attacker.pbThis))
    return 0
  end
end



################################################################################
# User is not Ghost: Decreases user's Speed, increases user's Attack & Defense by
# 1 stage each.
# User is Ghost: User loses 1/2 of max HP, and curses the target.
# Cursed Pokémon lose 1/4 of their max HP at the end of each round.
################################################################################
class PokeBattle_Move_10D < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    failed=false
    if !attacker.pbHasType?(:GHOST)
      lowerspeed=attacker.pbCanReduceStatStage?(PBStats::SPEED,false,true)
      raiseatk=attacker.pbCanIncreaseStatStage?(PBStats::ATTACK,false)
      raisedef=attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      if !lowerspeed && !raiseatk && !raisedef
        failed=true
      else
        pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation) # Placeholder for alternate move animation
        if lowerspeed
          attacker.pbReduceStat(PBStats::SPEED,1,false,true,true)
        end
        showanim=true
        if raiseatk
          attacker.pbIncreaseStat(PBStats::ATTACK,1,false,showanim)
          showanim=false
        end
        if raisedef
          attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
          showanim=false
        end
      end
    else
      if opponent.effects[PBEffects::Curse]
        failed=true
      else
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        attacker.pbReduceHP((attacker.totalhp/2).floor)
        opponent.effects[PBEffects::Curse]=true
        @battle.pbDisplay(_INTL("{1} cut its own HP and laid a curse on {2}!",attacker.pbThis,opponent.pbThis(true)))
      end
    end
    if failed
      @battle.pbDisplay(_INTL("But it failed!"))
    end
    return failed ? -1 : 0
  end
end



################################################################################
# Target's last move used loses 4 PP.
################################################################################
class PokeBattle_Move_10E < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    for i in opponent.moves
      if i.id==opponent.lastMoveUsed && i.id>0 && i.pp>0
        pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
        reduction=[4,i.pp].min
        i.pp-=reduction
        @battle.pbDisplay(_INTL("It reduced the PP of {1}'s {2} by {3}!",opponent.pbThis(true),i.name,reduction))
        return 0
      end
    end
    @battle.pbDisplay(_INTL("But it failed!"))
    return -1
  end
end



################################################################################
# Target will lose 1/4 of max HP at end of each round, while asleep.
################################################################################
class PokeBattle_Move_10F < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.status!=PBStatuses::SLEEP || opponent.effects[PBEffects::Nightmare] ||
       opponent.effects[PBEffects::Substitute]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Nightmare]=true
    @battle.pbDisplay(_INTL("{1} began having a nightmare!",opponent.pbThis))
    return 0
  end
end



################################################################################
# Removes trapping moves, entry hazards and Leech Seed on user/user's side.
################################################################################
class PokeBattle_Move_110 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if !attacker.isFainted? && opponent.damagestate.calcdamage>0
      if attacker.effects[PBEffects::MultiTurn]>0
        mtattack=PBMoves.getName(attacker.effects[PBEffects::MultiTurnAttack])
        mtuser=@battle.battlers[attacker.effects[PBEffects::MultiTurnUser]]
        @battle.pbDisplay(_INTL("{1} got free of {2}'s {3}!",attacker.pbThis,mtuser.pbThis(true),mtattack))
        attacker.effects[PBEffects::MultiTurn]=0
        attacker.effects[PBEffects::MultiTurnAttack]=0
        attacker.effects[PBEffects::MultiTurnUser]=-1
      end
      if attacker.effects[PBEffects::LeechSeed]>=0
        attacker.effects[PBEffects::LeechSeed]=-1
        @battle.pbDisplay(_INTL("{1} shed Leech Seed!",attacker.pbThis))   
      end
      if attacker.pbOwnSide.effects[PBEffects::StealthRock]
        attacker.pbOwnSide.effects[PBEffects::StealthRock]=false
        @battle.pbDisplay(_INTL("{1} blew away stealth rocks!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::Spikes]>0
        attacker.pbOwnSide.effects[PBEffects::Spikes]=0
        @battle.pbDisplay(_INTL("{1} blew away Spikes!",attacker.pbThis))     
      end
      if attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        attacker.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
        @battle.pbDisplay(_INTL("{1} blew away poison spikes!",attacker.pbThis))     
      end
    end
    return ret
  end
end



################################################################################
# Attacks 2 rounds in the future.
################################################################################
class PokeBattle_Move_111 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::FutureSight]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    damage=pbCalcDamage(attacker,opponent,
       PokeBattle_Move::NOCRITICAL|
       PokeBattle_Move::NOWEIGHTING|
       PokeBattle_Move::IGNOREPKMNTYPES)
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::FutureSight]=3 
    opponent.effects[PBEffects::FutureSightDamage]=damage
    opponent.effects[PBEffects::FutureSightMove]=@id
    opponent.effects[PBEffects::FutureSightUser]=attacker.index
    if isConst?(@id,PBMoves,:FUTURESIGHT)
      @battle.pbDisplay(_INTL("{1} foresaw an attack!",attacker.pbThis))
    else
      @battle.pbDisplay(_INTL("{1} chose Doom Desire as its destiny!",attacker.pbThis))
    end
    return 0
  end
end



################################################################################
# Increases user's Defense and Special Defense by 1 stage each.  Ups user's
# stockpile by 1 (max. 3).
################################################################################
class PokeBattle_Move_112 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Stockpile]>=3
      @battle.pbDisplay(_INTL("{1} can't stockpile any more!",attacker.pbThis))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::Stockpile]+=1
    @battle.pbDisplay(_INTL("{1} stockpiled {2}!",attacker.pbThis,
        attacker.effects[PBEffects::Stockpile]))
    showanim=true
    if attacker.pbCanIncreaseStatStage?(PBStats::DEFENSE,false)
      attacker.pbIncreaseStat(PBStats::DEFENSE,1,false,showanim)
      attacker.effects[PBEffects::StockpileDef]+=1
      showanim=false
    end
    if attacker.pbCanIncreaseStatStage?(PBStats::SPDEF,false)
      attacker.pbIncreaseStat(PBStats::SPDEF,1,false,showanim)
      attacker.effects[PBEffects::StockpileSpDef]+=1
      showanim=false
    end
    return 0
  end
end



################################################################################
# Power is multiplied by the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each.
################################################################################
class PokeBattle_Move_113 < PokeBattle_Move
  def pbBaseDamage(basedmg,attacker,opponent)
    return basedmg*attacker.effects[PBEffects::Stockpile]
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Stockpile]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    showanim=true
    if attacker.effects[PBEffects::StockpileDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef],
           false,showanim,true)
        showanim=false
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef],
           false,showanim,true)
        showanim=false
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return ret
  end
end



################################################################################
# Heals user depending on the user's stockpile (X).  Reduces the stockpile to 0.
# Decreases user's Defense and Special Defense by X stages each.
################################################################################
class PokeBattle_Move_114 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    hpgain=0
    case attacker.effects[PBEffects::Stockpile]
    when 0
      @battle.pbDisplay(_INTL("But it failed to swallow a thing!"))
      return -1
    when 1
      hpgain=(attacker.totalhp/4).floor
    when 2
      hpgain=(attacker.totalhp/2).floor
    when 3
      hpgain=attacker.totalhp
    end
    if attacker.hp==attacker.totalhp &&
       attacker.effects[PBEffects::StockpileDef]==0 &&
       attacker.effects[PBEffects::StockpileSpDef]==0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    if attacker.pbRecoverHP(hpgain,true)>0
      @battle.pbDisplay(_INTL("{1}'s HP was restored.",attacker.pbThis))
    end
    showanim=true
    if attacker.effects[PBEffects::StockpileDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::DEFENSE,false,true)
        attacker.pbReduceStat(PBStats::DEFENSE,attacker.effects[PBEffects::StockpileDef],
           false,showanim,true)
        showanim=false
      end
    end
    if attacker.effects[PBEffects::StockpileSpDef]>0
      if attacker.pbCanReduceStatStage?(PBStats::SPDEF,false,true)
        attacker.pbReduceStat(PBStats::SPDEF,attacker.effects[PBEffects::StockpileSpDef],
           false,showanim,true)
        showanim=false
      end
    end
    attacker.effects[PBEffects::Stockpile]=0
    attacker.effects[PBEffects::StockpileDef]=0
    attacker.effects[PBEffects::StockpileSpDef]=0
    @battle.pbDisplay(_INTL("{1}'s stockpiled effect wore off!",attacker.pbThis))
    return 0
  end
end



################################################################################
# Fails if user was hit by a damaging move this round.
################################################################################
class PokeBattle_Move_115 < PokeBattle_Move
  def pbDisplayUseMessage(attacker)
    if attacker.lastHPLost>0
      @battle.pbDisplayBrief(_INTL("{1} lost its focus and couldn't move!",attacker.pbThis))
      return -1
    end
    return super(attacker)
  end
end



################################################################################
# Fails if the target didn't chose a damaging move to use this round, or has
# already moved.
################################################################################
class PokeBattle_Move_116 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# This round, user becomes the target of attacks that have single targets.
################################################################################
class PokeBattle_Move_117 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !@battle.doublebattle
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::FollowMe]=true
    if !attacker.pbPartner.isFainted?
      attacker.pbPartner.effects[PBEffects::FollowMe]=false
    end
    @battle.pbDisplay(_INTL("{1} became the center of attention!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 5 rounds, increases gravity on the field.  Pokémon cannot become airborne.
################################################################################
class PokeBattle_Move_118 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if @battle.field.effects[PBEffects::Gravity]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    @battle.field.effects[PBEffects::Gravity]=5
    for i in 0...4
      poke=@battle.battlers[i]
      next if !poke
      if PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCC || # Bounce
         PBMoveData.new(poke.effects[PBEffects::TwoTurnAttack]).function==0xCE    # Sky Drop
        poke.effects[PBEffects::TwoTurnAttack]=0
      end
      if poke.effects[PBEffects::SkyDrop]
        poke.effects[PBEffects::SkyDrop]=false
      end
      if poke.effects[PBEffects::MagnetRise]>0
        poke.effects[PBEffects::MagnetRise]=0
      end
      if poke.effects[PBEffects::Telekinesis]>0
        poke.effects[PBEffects::Telekinesis]=0
      end
    end
    @battle.pbDisplay(_INTL("Gravity intensified!"))
    return 0
  end
end



################################################################################
# For 5 rounds, user becomes airborne.
################################################################################
class PokeBattle_Move_119 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if attacker.effects[PBEffects::Ingrain] ||
       attacker.effects[PBEffects::SmackDown] ||
       attacker.effects[PBEffects::MagnetRise]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,nil,hitnum,alltargets,showanimation)
    attacker.effects[PBEffects::MagnetRise]=5
    @battle.pbDisplay(_INTL("{1} levitated with electromagnetism!",attacker.pbThis))
    return 0
  end
end



################################################################################
# For 3 rounds, target becomes airborne and can always be hit.
################################################################################
class PokeBattle_Move_11A < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    return @battle.field.effects[PBEffects::Gravity]>0
  end

  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if opponent.effects[PBEffects::Ingrain] ||
       opponent.effects[PBEffects::SmackDown] ||
       opponent.effects[PBEffects::Telekinesis]>0
      @battle.pbDisplay(_INTL("But it failed!"))
      return -1
    end
    pbShowAnimation(@id,attacker,opponent,hitnum,alltargets,showanimation)
    opponent.effects[PBEffects::Telekinesis]=3
    @battle.pbDisplay(_INTL("{1} was hurled into the air!",opponent.pbThis))
    return 0
  end
end




################################################################################
# Hits airborne semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11B < PokeBattle_Move
# Handled in Battler class, do not edit!
end



################################################################################
# Grounds the target while it remains active.
# (Handled in Battler's pbSuccessCheck): Hits some semi-invulnerable targets.
################################################################################
class PokeBattle_Move_11C < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    ret=super(attacker,opponent,hitnum,alltargets,showanimation)
    if opponent.damagestate.calcdamage>0 && !opponent.damagestate.substitute &&
       !opponent.effects[PBEffects::Roost]
      opponent.effects[PBEffects::SmackDown]=true
      showmsg=false
      showmsg=true if opponent.pbHasType?(:FLYING) ||
                      opponent.hasWorkingAbility(:LEVITATE)
      if PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xC9 || # Fly
         PBMoveData.new(opponent.effects[PBEffects::TwoTurnAttack]).function==0xCC    # Bounce
        opponent.effects[PBEffects::TwoTurnAttack]=0; showmsg=true
      end
      if opponent.effects[PBEffects::MagnetRise]>0
        opponent.effects[PBEffects::MagnetRise]=0; showmsg=true
      end
      if opponent.effects[PBEffects::Telekinesis]>0
        opponent.effects[PBEffects::Telekinesis]=0; showmsg=true
      end
      @battle.pbDisplay(_INTL("{1} fell straight down!",opponent.pbThis)) if showmsg
    end
    return ret
  end
end



################################################################################
# Target moves immediately after the user, ignoring priority/speed.
################################################################################
class PokeBattle_Move_11D < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Target moves last this round, ignoring priority/speed.
################################################################################
class PokeBattle_Move_11E < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# For 5 rounds, for each priority bracket, slow Pokémon move before fast ones.
################################################################################
class PokeBattle_Move_11F < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# User switches places with its ally.
################################################################################
class PokeBattle_Move_120 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Target's Attack is used instead of user's Attack for this move's calculations.
################################################################################
class PokeBattle_Move_121 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# Target's Defense is used instead of its Special Defense for this move's
# calculations.
################################################################################
class PokeBattle_Move_122 < PokeBattle_Move
# Handled in superclass, do not edit!
end



################################################################################
# Only damages Pokémon that share a type with the user.
################################################################################
class PokeBattle_Move_123 < PokeBattle_Move
  def pbEffect(attacker,opponent,hitnum=0,alltargets=nil,showanimation=true)
    if !opponent.pbHasType?(attacker.type1) &&
       !opponent.pbHasType?(attacker.type2)
      @battle.pbDisplay(_INTL("{1} was unaffected!",opponent.pbThis))
      return -1
    end
    return super(attacker,opponent,hitnum,alltargets,showanimation)
  end
end



################################################################################
# For 5 rounds, swaps all battlers' base Defense with base Special Defense.
################################################################################
class PokeBattle_Move_124 < PokeBattle_UnimplementedMove
# Not implemented yet.
end



################################################################################
# Fails unless user has already used all other moves it knows.
################################################################################
class PokeBattle_Move_125 < PokeBattle_Move
  def pbMoveFailed(attacker,opponent)
    counter=0; nummoves=0
    for move in attacker.moves
      next if move.id<=0
      counter+=1 if move.id!=@id && !attacker.movesUsed.include?(move.id)
      nummoves+=1
    end
    return counter!=0 || nummoves==1
  end
end

#===============================================================================
# NOTE: Shadow moves use function codes 126-132 inclusive.  If you're inventing
#       new move effects, use function code 133 and onwards.
#===============================================================================