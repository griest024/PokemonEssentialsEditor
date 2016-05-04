# Results of battle:
#    0 - Undecided or aborted
#    1 - Player won
#    2 - Player lost
#    3 - Player or wild Pokémon ran from battle, or player forfeited the match
#    4 - Wild Pokémon was caught
#    5 - Draw
################################################################################
# Placeholder battle peer.
################################################################################
class PokeBattle_NullBattlePeer
  def pbStorePokemon(player,pokemon)
    if player.party.length<6
      player.party[player.party.length]=pokemon
    end
    return -1
  end

  def pbOnEnteringBattle(battle,pokemon)
  end

  def pbGetStorageCreator()
    return nil
  end

  def pbCurrentBox()
    return -1
  end

  def pbBoxName(box)
    return ""
  end
end



class PokeBattle_BattlePeer
  def self.create
    return PokeBattle_NullBattlePeer.new()
  end
end



################################################################################
# Success state (used for Battle Arena).
################################################################################
class PokeBattle_SuccessState
  attr_accessor :typemod
  attr_accessor :useState    # 0 - not used, 1 - failed, 2 - succeeded
  attr_accessor :protected
  attr_accessor :skill

  def initialize
    clear
  end

  def clear
    @typemod   = 4
    @useState  = 0
    @protected = false
    @skill     = 0
  end

  def updateSkill
    if @useState==1 && !@protected
      @skill-=2
    elsif @useState==2
      if @typemod>4
        @skill+=2 # "Super effective"
      elsif @typemod>=1 && @typemod<4
        @skill-=1 # "Not very effective"
      elsif @typemod==0
        @skill-=2 # Ineffective
      else
        @skill+=1
      end
    end
    @typemod=4
    @useState=0
    @protected=false
  end
end



################################################################################
# Catching and storing Pokémon.
################################################################################
module PokeBattle_BattleCommon
  def pbStorePokemon(pokemon)
    if !(pokemon.isShadow? rescue false)
      if pbDisplayConfirm(_INTL("Would you like to give a nickname to {1}?",pokemon.name))
        species=PBSpecies.getName(pokemon.species)
        nickname=@scene.pbNameEntry(_INTL("{1}'s nickname?",species),pokemon)
        pokemon.name=nickname if nickname!=""
      end
    end
    oldcurbox=@peer.pbCurrentBox()
    storedbox=@peer.pbStorePokemon(self.pbPlayer,pokemon)
    creator=@peer.pbGetStorageCreator()
    return if storedbox<0
    curboxname=@peer.pbBoxName(oldcurbox)
    boxname=@peer.pbBoxName(storedbox)
    if storedbox!=oldcurbox
      if creator
        pbDisplayPaused(_INTL("Box \"{1}\" on {2}'s PC was full.",curboxname,creator))
      else
        pbDisplayPaused(_INTL("Box \"{1}\" on someone's PC was full.",curboxname))
      end
      pbDisplayPaused(_INTL("{1} was transferred to box \"{2}\".",pokemon.name,boxname))
    else
      if creator
        pbDisplayPaused(_INTL("{1} was transferred to {2}'s PC.",pokemon.name,creator))
      else
        pbDisplayPaused(_INTL("{1} was transferred to someone's PC.",pokemon.name))
      end
      pbDisplayPaused(_INTL("It was stored in box \"{1}\".",boxname))
    end
  end

  def pbThrowPokeBall(idxPokemon,ball,rareness=nil,showplayer=false)
    itemname=PBItems.getName(ball)
    battler=nil
    if pbIsOpposing?(idxPokemon)
      battler=self.battlers[idxPokemon]
    else
      battler=self.battlers[idxPokemon].pbOppositeOpposing
    end
    if battler.isFainted?
      battler=battler.pbPartner
    end
    pbDisplayBrief(_INTL("{1} threw one {2}!",self.pbPlayer.name,itemname))
    if battler.isFainted?
      pbDisplay(_INTL("But there was no target..."))
      return
    end
    if @opponent && (!pbIsSnagBall?(ball) || !battler.isShadow?)
      @scene.pbThrowAndDeflect(ball,1)
      pbDisplay(_INTL("The Trainer blocked the Ball!\nDon't be a thief!"))
    else
      pokemon=battler.pokemon
      species=pokemon.species
      if $DEBUG && Input.press?(Input::CTRL)
        shakes=4
      else
        if !rareness
          dexdata=pbOpenDexData
          pbDexDataOffset(dexdata,species,16)
          rareness=dexdata.fgetb # Get rareness from dexdata file
          dexdata.close
        end
        a=battler.totalhp
        b=battler.hp
        rareness=BallHandlers.modifyCatchRate(ball,rareness,self,battler)
        x=(((a*3-b*2)*rareness)/(a*3)).floor
        if battler.status==PBStatuses::SLEEP || battler.status==PBStatuses::FROZEN
          x*=2
        elsif battler.status!=0
          x=(x*3/2).floor
        end
        shakes=0
        if x>255 || BallHandlers.isUnconditional?(ball,self,battler)
          shakes=4
        else
          x=1 if x==0
          y = 0x000FFFF0 / (Math.sqrt(Math.sqrt( 0x00FF0000/x ) ) )
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y
          shakes+=1 if pbRandom(65536)<y 
        end
      end
      PBDebug.log("[Player threw a #{itemname}, #{shakes} shakes (4=capture)]")
      @scene.pbThrow(ball,shakes,battler.index,showplayer)
      case shakes
      when 0
        pbDisplay(_INTL("Oh no!  The Pokémon broke free!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
      when 1
        pbDisplay(_INTL("Aww... It appeared to be caught!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
      when 2
        pbDisplay(_INTL("Aargh!  Almost had it!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
      when 3
        pbDisplay(_INTL("Shoot!  It was so close, too!"))
        BallHandlers.onFailCatch(ball,self,pokemon)
      when 4
        pbDisplayBrief(_INTL("Gotcha!  {1} was caught!",pokemon.name))
        @scene.pbThrowSuccess
        if pbIsSnagBall?(ball) && @opponent
          pbRemoveFromParty(battler.index,battler.pokemonIndex)
          battler.pbReset
          battler.participants=[]
        else
          @decision=4
        end
        if pbIsSnagBall?(ball)
          pokemon.ot=self.pbPlayer.name
          pokemon.trainerID=self.pbPlayer.id
        end
        BallHandlers.onCatch(ball,self,pokemon)
        pokemon.ballused=pbGetBallType(ball)
        pokemon.pbRecordFirstMoves
        if !self.pbPlayer.owned[species]
          self.pbPlayer.owned[species]=true
          if $Trainer.pokedex
            pbDisplayPaused(_INTL("{1}'s data was added to the Pokédex.",pokemon.name))
            @scene.pbShowPokedex(species)
          end
        end
        @scene.pbHideCaptureBall
        if pbIsSnagBall?(ball) && @opponent
          pokemon.pbUpdateShadowMoves rescue nil
          @snaggedpokemon.push(pokemon)
        else
          pbStorePokemon(pokemon)
        end
      end
    end
  end
end



################################################################################
# Main battle class.
################################################################################
class PokeBattle_Battle
  attr_reader(:scene)             # Scene object for this battle
  attr_accessor(:decision)        # Decision: 0=undecided; 1=win; 2=loss; 3=escaped; 4=caught
  attr_accessor(:internalbattle)  # Internal battle flag
  attr_accessor(:doublebattle)    # Double battle flag
  attr_accessor(:cantescape)      # True if player can't escape
  attr_accessor(:shiftStyle)      # Shift/Set "battle style" option
  attr_accessor(:battlescene)     # "Battle scene" option
  attr_accessor(:debug)           # Debug flag
  attr_reader(:player)            # Player trainer
  attr_reader(:opponent)          # Opponent trainer
  attr_reader(:party1)            # Player's Pokémon party
  attr_reader(:party2)            # Foe's Pokémon party
  attr_reader(:partyorder)        # Order of Pokémon in the player's party
  attr_accessor(:fullparty1)      # True if player's party's max size is 6 instead of 3
  attr_accessor(:fullparty2)      # True if opponent's party's max size is 6 instead of 3
  attr_reader(:battlers)          # Currently active Pokémon
  attr_accessor(:items)           # Items held by opponents
  attr_reader(:sides)             # Effects common to each side of a battle
  attr_reader(:field)             # Effects common to the whole of a battle
  attr_accessor(:environment)     # Battle surroundings
  attr_accessor(:weather)         # Current weather, custom methods should use pbWeather instead
  attr_accessor(:weatherduration) # Duration of current weather, or -1 if indefinite
  attr_reader(:switching)         # True if during the switching phase of the round
  attr_reader(:struggle)          # The Struggle move
  attr_accessor(:choices)         # Choices made by each Pokémon this round
  attr_reader(:successStates)     # Success states
  attr_accessor(:lastMoveUsed)    # Last move used
  attr_accessor(:lastMoveUser)    # Last move user
  attr_accessor(:synchronize)     # Synchronize state
  attr_accessor(:megaEvolution)   # Battle index of each trainer's Pokémon to Mega Evolve
  attr_accessor(:amuletcoin)      # Whether Amulet Coin's effect applies
  attr_accessor(:extramoney)      # Money gained in battle by using Pay Day
  attr_accessor(:endspeech)       # Speech by opponent when player wins
  attr_accessor(:endspeech2)      # Speech by opponent when player wins
  attr_accessor(:endspeechwin)    # Speech by opponent when opponent wins
  attr_accessor(:endspeechwin2)   # Speech by opponent when opponent wins
  attr_accessor(:rules)
  attr_reader(:turncount)
  attr_accessor :controlPlayer
  include PokeBattle_BattleCommon
  
  MAXPARTYSIZE = 6

  class BattleAbortedException < Exception; end

  def pbAbort
    raise BattleAbortedException.new("Battle aborted")
  end

  def pbDebugUpdate
  end

  def pbRandom(x)
    return rand(x)
  end

  def pbAIRandom(x)
    return rand(x)
  end

################################################################################
# Initialise battle class.
################################################################################
  def initialize(scene,p1,p2,player,opponent)
    if p1.length==0
      raise ArgumentError.new(_INTL("Party 1 has no Pokémon."))
      return
    end
    if p2.length==0
      raise ArgumentError.new(_INTL("Party 2 has no Pokémon."))
      return
    end
    if p2.length>2 && !opponent
      raise ArgumentError.new(_INTL("Wild battles with more than two Pokémon are not allowed."))
      return
    end
    @scene           = scene
    @decision        = 0
    @internalbattle  = true
    @doublebattle    = false
    @cantescape      = false
    @shiftStyle      = true
    @battlescene     = true
    @debug           = false
    @debugupdate     = 0
    if opponent && player.is_a?(Array) && player.length==0
      player = player[0]
    end
    if opponent && opponent.is_a?(Array) && opponent.length==0
      opponent = opponent[0]
    end
    @player          = player                # PokeBattle_Trainer object
    @opponent        = opponent              # PokeBattle_Trainer object
    @party1          = p1
    @party2          = p2
    @partyorder      = []
    for i in 0...6; @partyorder.push(i); end
    @fullparty1      = false
    @fullparty2      = false
    @battlers        = []
    @items           = nil
    @sides           = [PokeBattle_ActiveSide.new,   # Player's side
                        PokeBattle_ActiveSide.new]   # Foe's side
    @field           = PokeBattle_ActiveField.new    # Whole field (gravity/rooms)
    @environment     = PBEnvironment::None   # e.g. Tall grass, cave, still water
    @weather         = 0
    @weatherduration = 0
    @switching       = false
    @choices         = [ [0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1],[0,0,nil,-1] ]
    @successStates   = []
    for i in 0...4
      @successStates.push(PokeBattle_SuccessState.new)
    end
    @lastMoveUsed    = -1
    @lastMoveUser    = -1
    @synchronize     = [-1,-1,0]
    @megaEvolution   = []
    if @player.is_a?(Array)
      @megaEvolution[0]=[-1]*@player.length
    else
      @megaEvolution[0]=[-1]
    end
    if @opponent.is_a?(Array)
      @megaEvolution[1]=[-1]*@opponent.length
    else
      @megaEvolution[1]=[-1]
    end
    @amuletcoin      = false
    @extramoney      = 0
    @endspeech       = ""
    @endspeech2      = ""
    @endspeechwin    = ""
    @endspeechwin2   = ""
    @rules           = {}
    @turncount       = 0
    @peer            = PokeBattle_BattlePeer.create()
    @priority        = []
    @usepriority     = false
    @snaggedpokemon  = []
    @runCommand      = 0
    if hasConst?(PBMoves,:STRUGGLE)
      @struggle = PokeBattle_Move.pbFromPBMove(self,PBMove.new(getConst(PBMoves,:STRUGGLE)))
    else
      @struggle = PokeBattle_Struggle.new(self,nil)
    end
    @struggle.pp     = -1
    for i in 0...4
      battlers[i] = PokeBattle_Battler.new(self,i)
    end
    for i in @party1
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
    for i in @party2
      next if !i
      i.itemRecycle = 0
      i.itemInitial = i.item
    end
  end

################################################################################
# Info about battle.
################################################################################
  def pbDoubleBattleAllowed?
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      return false
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      return false
    end
    _opponent=@opponent
    _player=@player
    # Wild battle
    if !_opponent
      if @party2.length==1
        return false
      elsif @party2.length==2
        return true
      else
        return false
      end
    # Trainer battle
    else
      if _opponent.is_a?(Array)
        if _opponent.length==1
          _opponent=_opponent[0]
        elsif _opponent.length!=2
          return false
        end
      end
      _player=_player
      if _player.is_a?(Array)
        if _player.length==1
          _player=_player[0]
        elsif _player.length!=2
          return false
        end
      end
      if _opponent.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        return false if sendout1<0 || sendout2<0
      else
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        return false if sendout1<0 || sendout2<0
      end
    end
    if _player.is_a?(Array)
      sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
      sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
      return false if sendout1<0 || sendout2<0
    else
      sendout1=pbFindNextUnfainted(@party1,0)
      sendout2=pbFindNextUnfainted(@party1,sendout1+1)
      return false if sendout1<0 || sendout2<0
    end
    return true
  end

  def pbWeather
    for i in 0...4
      if @battlers[i].hasWorkingAbility(:CLOUDNINE) ||
         @battlers[i].hasWorkingAbility(:AIRLOCK)
        return 0
      end
    end
    return @weather
  end

################################################################################
# Get battler info.
################################################################################
  def pbIsOpposing?(index)
    return (index%2)==1
  end

  def pbOwnedByPlayer?(index)
    return false if pbIsOpposing?(index)
    return false if @player.is_a?(Array) && index==2
    return true
  end

  def pbIsDoubleBattler?(index)
    return (index>=2)
  end

  def pbThisEx(battlerindex,pokemonindex)
    party=pbParty(battlerindex)
    if pbIsOpposing?(battlerindex)
      if @opponent
        return _INTL("The foe {1}",party[pokemonindex].name)
      else
        return _INTL("The wild {1}",party[pokemonindex].name)
      end
    else
      return _INTL("{1}",party[pokemonindex].name)
    end
  end

# Checks whether an item can be removed from a Pokémon.
  def pbIsUnlosableItem(pkmn,item)
    return true if pbIsMail?(item)
    return false if pkmn.effects[PBEffects::Transform]
    if isConst?(pkmn.ability,PBAbilities,:MULTITYPE) &&
       (isConst?(item,PBItems,:FISTPLATE) ||
        isConst?(item,PBItems,:SKYPLATE) ||
        isConst?(item,PBItems,:TOXICPLATE) ||
        isConst?(item,PBItems,:EARTHPLATE) ||
        isConst?(item,PBItems,:STONEPLATE) ||
        isConst?(item,PBItems,:INSECTPLATE) ||
        isConst?(item,PBItems,:SPOOKYPLATE) ||
        isConst?(item,PBItems,:IRONPLATE) ||
        isConst?(item,PBItems,:FLAMEPLATE) ||
        isConst?(item,PBItems,:SPLASHPLATE) ||
        isConst?(item,PBItems,:MEADOWPLATE) ||
        isConst?(item,PBItems,:ZAPPLATE) ||
        isConst?(item,PBItems,:MINDPLATE) ||
        isConst?(item,PBItems,:ICICLEPLATE) ||
        isConst?(item,PBItems,:DRACOPLATE) ||
        isConst?(item,PBItems,:DREADPLATE))
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GIRATINA) &&
       isConst?(item,PBItems,:GRISEOUSORB)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:GENESECT) &&
       (isConst?(item,PBItems,:SHOCKDRIVE) ||
        isConst?(item,PBItems,:BURNDRIVE) ||
        isConst?(item,PBItems,:CHILLDRIVE) ||
        isConst?(item,PBItems,:DOUSEDRIVE))
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:VENUSAUR) &&
       isConst?(item,PBItems,:VENUSAURITE)
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:CHARIZARD) &&
       (isConst?(item,PBItems,:CHARIZARDITEX) ||
        isConst?(item,PBItems,:CHARIZARDITEY))
      return true
    end
    if isConst?(pkmn.species,PBSpecies,:BLASTOISE) &&
       isConst?(item,PBItems,:BLASTOISINITE)
      return true
    end
    return false
  end

  def pbCheckGlobalAbility(a)
    for i in 0...4 # in order from own first, opposing first, own second, opposing second
      if @battlers[i].hasWorkingAbility(a)
        return @battlers[i]
      end
    end
    return nil
  end

################################################################################
# Player-related info.
################################################################################
  def pbPlayer
    if @player.is_a?(Array)
      return @player[0]
    else
      return @player
    end
  end

  def pbGetOwnerItems(battlerIndex)
    return [] if !@items
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @items[0] : @items[1]
      else
        return @items
      end
    else
      return []
    end
  end

  def pbSetSeen(pokemon)
    if pokemon && @internalbattle
      self.pbPlayer.seen[pokemon.species]=true
      pbSeenForm(pokemon)
    end
  end

################################################################################
# Get party info, manipulate parties.
################################################################################
  def pbPokemonCount(party)
    count=0
    for i in party
      next if !i
      count+=1 if i.hp>0 && !i.isEgg?
    end
    return count
  end

  def pbAllFainted?(party)
    pbPokemonCount(party)==0
  end

  def pbMaxLevel(party)
    lv=0
    for i in party
      next if !i
      lv=i.level if lv<i.level
    end
    return lv
  end

  def pbMaxLevelFromIndex(index)
    party=pbParty(index)
    owner=(pbIsOpposing?(index)) ? @opponent : @player
    maxlevel=0
    if owner.is_a?(Array)
      start=0
      limit=pbSecondPartyBegin(index)
      start=limit if pbIsDoubleBattler?(index)
      for i in start...start+limit
        next if !party[i]
        maxlevel=party[i].level if maxlevel<party[i].level
      end
    else
      for i in party
        next if !i
        maxlevel=i.level if maxlevel<i.level
      end
    end
    return maxlevel
  end

  def pbParty(index)
    return pbIsOpposing?(index) ? party2 : party1
  end

  def pbSecondPartyBegin(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return @fullparty2 ? 6 : 3
    else
      return @fullparty1 ? 6 : 3
    end
  end

  def pbFindNextUnfainted(party,start,finish=-1)
    finish=party.length if finish<0
    for i in start...finish
      next if !party[i]
      return i if party[i].hp>0 && !party[i].isEgg?
    end
    return -1
  end

  def pbFindPlayerBattler(pkmnIndex)
    battler=nil
    for k in 0...4
      if !pbIsOpposing?(k) && @battlers[k].pokemonIndex==pkmnIndex
        battler=@battlers[k]
        break
      end
    end
    return battler
  end

  def pbIsOwner?(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return true if !@player || !@player.is_a?(Array)
      return (battlerIndex==0) ? partyIndex<secondParty : partyIndex>=secondParty
    else
      return true if !@opponent || !@opponent.is_a?(Array)
      return (battlerIndex==1) ? partyIndex<secondParty : partyIndex>=secondParty
    end
  end

  def pbGetOwner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[0] : @opponent[1]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[0] : @player[1]
      else
        return @player
      end
    end
  end

  def pbGetOwnerPartner(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      if @opponent.is_a?(Array)
        return (battlerIndex==1) ? @opponent[1] : @opponent[0]
      else
        return @opponent
      end
    else
      if @player.is_a?(Array)
        return (battlerIndex==0) ? @player[1] : @player[0]
      else
        return @player
      end
    end
  end

  def pbGetOwnerIndex(battlerIndex)
    if pbIsOpposing?(battlerIndex)
      return (@opponent.is_a?(Array)) ? ((battlerIndex==1) ? 0 : 1) : 0
    else
      return (@player.is_a?(Array)) ? ((battlerIndex==0) ? 0 : 1) : 0
    end
  end

  def pbBelongsToPlayer?(battlerIndex)
    if @player.is_a?(Array) && @player.length>1
      return battlerIndex==0
    else
      return (battlerIndex%2)==0
    end
    return false
  end

  def pbPartyGetOwner(battlerIndex,partyIndex)
    secondParty=pbSecondPartyBegin(battlerIndex)
    if !pbIsOpposing?(battlerIndex)
      return @player if !@player || !@player.is_a?(Array)
      return (partyIndex<secondParty) ? @player[0] : @player[1]
    else
      return @opponent if !@opponent || !@opponent.is_a?(Array)
      return (partyIndex<secondParty) ? @opponent[0] : @opponent[1]
    end
  end

  def pbAddToPlayerParty(pokemon)
    party=pbParty(0)
    for i in 0...party.length
      party[i]=pokemon if pbIsOwner?(0,i) && !party[i]
    end
  end

  def pbRemoveFromParty(battlerIndex,partyIndex)
    party=pbParty(battlerIndex)
    side=(pbIsOpposing?(battlerIndex)) ? @opponent : @player
    party[partyIndex]=nil
    if !side || !side.is_a?(Array) # Wild or single opponent
      party.compact!
      for i in battlerIndex...party.length
        for j in 0..3
          next if !@battlers[j]
          if pbGetOwner(j)==side && @battlers[j].pokemonIndex==i
            @battlers[j].pokemonIndex-=1
            break
          end
        end
      end
    else
      if battlerIndex<pbSecondPartyBegin(battlerIndex)-1
        for i in battlerIndex...pbSecondPartyBegin(battlerIndex)
          if i>=pbSecondPartyBegin(battlerIndex)-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      else
        for i in battlerIndex...party.length
          if i>=party.length-1
            party[i]=nil
          else
            party[i]=party[i+1]
          end
        end
      end
    end
  end

################################################################################
# Check whether actions can be taken.
################################################################################
  def pbCanShowCommands?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    return false if thispkmn.isFainted?
    return false if thispkmn.effects[PBEffects::TwoTurnAttack]>0
    return false if thispkmn.effects[PBEffects::HyperBeam]>0
    return false if thispkmn.effects[PBEffects::Rollout]>0
    return false if thispkmn.effects[PBEffects::Outrage]>0
    return false if thispkmn.effects[PBEffects::Uproar]>0
    return false if thispkmn.effects[PBEffects::Bide]>0
    return true
  end

################################################################################
# Attacking.
################################################################################
  def pbCanShowFightMenu?(idxPokemon)
    thispkmn=@battlers[idxPokemon]
    if !pbCanShowCommands?(idxPokemon)
      return false
    end
    # No moves that can be chosen
    if !pbCanChooseMove?(idxPokemon,0,false) &&
       !pbCanChooseMove?(idxPokemon,1,false) &&
       !pbCanChooseMove?(idxPokemon,2,false) &&
       !pbCanChooseMove?(idxPokemon,3,false)
      return false
    end
    # Encore
    return false if thispkmn.effects[PBEffects::Encore]>0
    return true
  end

  def pbCanChooseMove?(idxPokemon,idxMove,showMessages,sleeptalk=false)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    if !thismove||thismove.id==0
      return false
    end
    if thismove.pp<=0 && thismove.totalpp>0 && !sleeptalk
      if showMessages
        pbDisplayPaused(_INTL("There's no PP left for this move!"))
      end
      return false
    end
    if thispkmn.effects[PBEffects::ChoiceBand]>=0 &&
       (thispkmn.hasWorkingItem(:CHOICEBAND) ||
       thispkmn.hasWorkingItem(:CHOICESPECS) ||
       thispkmn.hasWorkingItem(:CHOICESCARF))
      hasmove=false
      for i in 0...4
        if thispkmn.moves[i].id==thispkmn.effects[PBEffects::ChoiceBand]
          hasmove=true
          break
        end
      end
      if hasmove && thismove.id!=thispkmn.effects[PBEffects::ChoiceBand]
        if showMessages
          pbDisplayPaused(_INTL("{1} allows the use of only {2}!",
             PBItems.getName(thispkmn.item),
             PBMoves.getName(thispkmn.effects[PBEffects::ChoiceBand])))
        end
        return false
      end
    end
    if opp1.effects[PBEffects::Imprison]
      if thismove.id==opp1.moves[0].id ||
         thismove.id==opp1.moves[1].id ||
         thismove.id==opp1.moves[2].id ||
         thismove.id==opp1.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
       #PBDebug.log("[CanChoose][#{opp1.pbThis} has: #{opp1.moves[0].name}, #{opp1.moves[1].name},#{opp1.moves[2].name},#{opp1.moves[3].name}]")
        return false
      end
    end
    if opp2.effects[PBEffects::Imprison]
      if thismove.id==opp2.moves[0].id ||
         thismove.id==opp2.moves[1].id ||
         thismove.id==opp2.moves[2].id ||
         thismove.id==opp2.moves[3].id
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the sealed {2}!",thispkmn.pbThis,thismove.name))
        end
        #PBDebug.log("[CanChoose][#{opp2.pbThis} has: #{opp2.moves[0].name}, #{opp2.moves[1].name},#{opp2.moves[2].name},#{opp2.moves[3].name}]")
        return false
      end
    end
    if thispkmn.effects[PBEffects::Taunt]>0 && thismove.basedamage==0
      if showMessages
        pbDisplayPaused(_INTL("{1} can't use {2} after the Taunt!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Torment]
      if thismove.id==thispkmn.lastMoveUsed
        if showMessages
          pbDisplayPaused(_INTL("{1} can't use the same move in a row due to the torment!",thispkmn.pbThis))
        end
        return false
      end
    end
    if thismove.id==thispkmn.effects[PBEffects::DisableMove] && !sleeptalk
      if showMessages
        pbDisplayPaused(_INTL("{1}'s {2} is disabled!",thispkmn.pbThis,thismove.name))
      end
      return false
    end
    if thispkmn.effects[PBEffects::Encore]>0 && idxMove!=thispkmn.effects[PBEffects::EncoreIndex]
      return false
    end
    return true
  end

  def pbAutoChooseMove(idxPokemon,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    if thispkmn.isFainted?
      @choices[idxPokemon][0]=0
      @choices[idxPokemon][1]=0
      @choices[idxPokemon][2]=nil
      return
    end
    if thispkmn.effects[PBEffects::Encore]>0 && 
       pbCanChooseMove?(idxPokemon,thispkmn.effects[PBEffects::EncoreIndex],false)
      PBDebug.log("[Auto choosing Encore move...]")
      @choices[idxPokemon][0]=1    # "Use move"
      @choices[idxPokemon][1]=thispkmn.effects[PBEffects::EncoreIndex] # Index of move
      @choices[idxPokemon][2]=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
      @choices[idxPokemon][3]=-1   # No target chosen yet
      if @doublebattle
        thismove=thispkmn.moves[thispkmn.effects[PBEffects::EncoreIndex]]
        target=thispkmn.pbTarget(thismove)
        if target==PBTargets::SingleNonUser
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0
        elsif target==PBTargets::UserOrPartner
          target=@scene.pbChooseTarget(idxPokemon)
          pbRegisterTarget(idxPokemon,target) if target>=0 && (target&1)==(idxPokemon&1)
        end
      end
    else
      if !pbIsOpposing?(idxPokemon)
        pbDisplayPaused(_INTL("{1} has no moves left!",thispkmn.name)) if showMessages
      end
      @choices[idxPokemon][0]=1           # "Use move"
      @choices[idxPokemon][1]=-1          # Index of move to be used
      @choices[idxPokemon][2]=@struggle   # Use Struggle
      @choices[idxPokemon][3]=-1          # No target chosen yet
    end
  end

  def pbRegisterMove(idxPokemon,idxMove,showMessages=true)
    thispkmn=@battlers[idxPokemon]
    thismove=thispkmn.moves[idxMove]
    return false if !pbCanChooseMove?(idxPokemon,idxMove,showMessages)
    @choices[idxPokemon][0]=1         # "Use move"
    @choices[idxPokemon][1]=idxMove   # Index of move to be used
    @choices[idxPokemon][2]=thismove  # PokeBattle_Move object of the move
    @choices[idxPokemon][3]=-1        # No target chosen yet
    return true
  end

  def pbChoseMove?(i,move)
    return false if @battlers[i].isFainted?
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return isConst?(@battlers[i].moves[choice].id,PBMoves,move)
    end
    return false
  end

  def pbChoseMoveFunctionCode?(i,code)
    return false if @battlers[i].isFainted?
    if @choices[i][0]==1 && @choices[i][1]>=0
      choice=@choices[i][1]
      return @battlers[i].moves[choice].function==code
    end
    return false
  end

  def pbRegisterTarget(idxPokemon,idxTarget)
    @choices[idxPokemon][3]=idxTarget   # Set target of move
    return true
  end

  def pbPriority(ignorequickclaw=false)
    if @usepriority
      # use stored priority if round isn't over yet
      return @priority
    end
    speeds=[]
    quickclaw=[]
    priorities=[]
    temp=[]
    @priority.clear
    maxpri=0
    minpri=0
    # Calculate each Pokémon's speed
    for i in 0...4
      speeds[i]=@battlers[i].pbSpeed
      quickclaw[i]=@battlers[i].hasWorkingItem(:QUICKCLAW)
      quickclaw[i]=false if @choices[i][0]!=1
      quickclaw[i]=false if !(pbRandom(100)<20)
      quickclaw[i]=false if ignorequickclaw
    end
    # Find the maximum and minimum priority
    for i in 0...4
      # For this function, switching and using items
      # is the same as using a move with a priority of 0
      pri=0
      if @choices[i][0]==1 # Is a move
        pri=@choices[i][2].priority
        pri+=1 if @battlers[i].hasWorkingAbility(:PRANKSTER) &&
                  @choices[i][2].basedamage==0 # Is status move
      end
      priorities[i]=pri
      if i==0
        maxpri=pri
        minpri=pri
      else
        maxpri=pri if maxpri<pri
        minpri=pri if minpri>pri
      end
    end
    # Find and order all moves with the same priority
    curpri=maxpri
    loop do
      temp.clear
      for j in 0...4
        if priorities[j]==curpri
          temp[temp.length]=j
        end
      end
      # Sort by speed
      if temp.length==1
        @priority[@priority.length]=@battlers[temp[0]]
      else
        n=temp.length
        for m in 0..n-2
          for i in 1..n-1
            if quickclaw[temp[i]]
              cmp=(quickclaw[temp[i-1]]) ? 0 : -1 #Rank higher if without Quick Claw, or equal if with it
            elsif quickclaw[temp[i-1]]
              cmp=1 # Rank lower
            elsif speeds[temp[i]]!=speeds[temp[i-1]]
              cmp=(speeds[temp[i]]>speeds[temp[i-1]]) ? -1 : 1 #Rank higher to higher-speed battler
            else
              cmp=0
            end
            if cmp<0
              # put higher-speed Pokémon first
              swaptmp=temp[i]
              temp[i]=temp[i-1]
              temp[i-1]=swaptmp
            elsif cmp==0
              # swap at random if speeds are equal
              if pbRandom(2)==0
                swaptmp=temp[i]
                temp[i]=temp[i-1]
                temp[i-1]=swaptmp
              end
            end
          end
        end
        #Now add the temp array to priority
        for i in temp
          @priority[@priority.length]=@battlers[i]
        end
      end
      curpri-=1
      break unless curpri>=minpri
    end
=begin
    prioind=[
       @priority[0].index,
       @priority[1].index,
       @priority[2] ? @priority[2].index : -1,
       @priority[3] ? @priority[3].index : -1
    ]
    print("#{speeds.inspect} #{prioind.inspect}")
=end
    @usepriority=true
    d="   Priority: #{@priority[0].index}"
    d+=", #{@priority[1].index}" if @priority[1]
    d+=", #{@priority[2].index}" if @priority[2]
    d+=", #{@priority[3].index}" if @priority[3]
    PBDebug.log(d)
    return @priority
  end

################################################################################
# Switching Pokémon.
################################################################################
  def pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
    if pkmnidxTo>=0
      party=pbParty(idxPokemon)
      if pkmnidxTo>=party.length
        return false
      end
      if !party[pkmnidxTo]
        return false
      end
      if party[pkmnidxTo].isEgg?
        pbDisplayPaused(_INTL("An Egg can't battle!")) if showMessages 
        return false
      end
      if !pbIsOwner?(idxPokemon,pkmnidxTo)
        owner=pbPartyGetOwner(idxPokemon,pkmnidxTo)
        pbDisplayPaused(_INTL("You can't switch {1}'s Pokémon with one of yours!",owner.name)) if showMessages 
        return false
      end
      if party[pkmnidxTo].hp<=0
        pbDisplayPaused(_INTL("{1} has no energy left to battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end   
      if @battlers[idxPokemon].pokemonIndex==pkmnidxTo ||
         @battlers[idxPokemon].pbPartner.pokemonIndex==pkmnidxTo
        pbDisplayPaused(_INTL("{1} is already in battle!",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    return true
  end

  def pbCanSwitch?(idxPokemon,pkmnidxTo,showMessages)
    thispkmn=@battlers[idxPokemon]
    # Multi-Turn Attacks/Mean Look
    if !pbCanSwitchLax?(idxPokemon,pkmnidxTo,showMessages)
      return false
    end
    isOpposing=pbIsOpposing?(idxPokemon)
    party=pbParty(idxPokemon)
    for i in 0...4
      next if isOpposing!=pbIsOpposing?(i)
      if choices[i][0]==2 && choices[i][1]==pkmnidxTo
        pbDisplayPaused(_INTL("{1} has already been selected.",party[pkmnidxTo].name)) if showMessages 
        return false
      end
    end
    if thispkmn.hasWorkingItem(:SHEDSHELL)
      return true
    end
    if thispkmn.effects[PBEffects::MultiTurn]>0 ||
       thispkmn.effects[PBEffects::MeanLook]>=0
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    # Ingrain
    if thispkmn.effects[PBEffects::Ingrain]
      pbDisplayPaused(_INTL("{1} can't be switched out!",thispkmn.pbThis)) if showMessages
      return false
    end
    opp1=thispkmn.pbOpposing1
    opp2=thispkmn.pbOpposing2
    opp=nil
    if thispkmn.pbHasType?(:STEEL)
      opp=opp1 if opp1.hasWorkingAbility(:MAGNETPULL)
      opp=opp2 if opp2.hasWorkingAbility(:MAGNETPULL)
    end
    if !thispkmn.isAirborne?
      opp=opp1 if opp1.hasWorkingAbility(:ARENATRAP)
      opp=opp2 if opp2.hasWorkingAbility(:ARENATRAP)
    end
    if !thispkmn.hasWorkingAbility(:SHADOWTAG)
      opp=opp1 if opp1.hasWorkingAbility(:SHADOWTAG)
      opp=opp2 if opp2.hasWorkingAbility(:SHADOWTAG)
    end
    if opp
      abilityname=PBAbilities.getName(opp.ability)
      pbDisplayPaused(_INTL("{1}'s {2} prevents switching!",opp.pbThis,abilityname)) if showMessages
      return false
    end
    return true
  end

  def pbRegisterSwitch(idxPokemon,idxOther)
    return false if !pbCanSwitch?(idxPokemon,idxOther,false)
    @choices[idxPokemon][0]=2          # "Switch Pokémon"
    @choices[idxPokemon][1]=idxOther   # Index of other Pokémon to switch with
    @choices[idxPokemon][2]=nil
    side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    owner=pbGetOwnerIndex(idxPokemon)
    if @megaEvolution[side][owner]==idxPokemon
      @megaEvolution[side][owner]=-1
    end
    return true
  end

  def pbCanChooseNonActive?(index)
    party=pbParty(index)
    for i in 0..party.length-1
      return true if pbCanSwitchLax?(index,i,false)
    end
    return false
  end

  def pbSwitch(favorDraws=false)
    if !favorDraws
      return if @decision>0
      pbJudge()
      return if @decision>0
    else
      return if @decision==5
      pbJudge()
      return if @decision>0
    end
    firstbattlerhp=@battlers[0].hp
    switched=[]
    for index in 0...4
      next if !@doublebattle && pbIsDoubleBattler?(index)
      next if @battlers[index] && !@battlers[index].isFainted?
      next if !pbCanChooseNonActive?(index)
      if !pbOwnedByPlayer?(index)
        if !pbIsOpposing?(index) || (@opponent && pbIsOpposing?(index))
          newenemy=pbSwitchInBetween(index,false,false)
          opponent=pbGetOwner(index)
          if !@doublebattle && firstbattlerhp>0 && @shiftStyle && @opponent &&
              @internalbattle && pbCanChooseNonActive?(0) && pbIsOpposing?(index) &&
              @battlers[0].effects[PBEffects::Outrage]==0
            pbDisplayPaused(_INTL("{1} is about to send in {2}.",opponent.fullname,@party2[newenemy].name))
            if pbDisplayConfirm(_INTL("Will {1} change Pokémon?",self.pbPlayer.name))
              newpoke=pbSwitchPlayer(0,true,true)
              if newpoke>=0
                pbDisplayBrief(_INTL("{1}, that's enough!  Come back!",@battlers[0].name))
                pbRecallAndReplace(0,newpoke)
                switched.push(0)
              end
            end
          end
          pbRecallAndReplace(index,newenemy)
          switched.push(index)
        end
      elsif @opponent
        newpoke=pbSwitchInBetween(index,true,false)
        pbRecallAndReplace(index,newpoke)
        switched.push(index)
      else
        switch=false
        if !pbDisplayConfirm(_INTL("Use next Pokémon?")) 
          switch=(pbRun(index,true)<=0)
        else
          switch=true
        end
        if switch
          newpoke=pbSwitchInBetween(index,true,false)
          pbRecallAndReplace(index,newpoke)
          switched.push(index)
        end
      end
    end
    if switched.length>0
      priority=pbPriority
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
  end

  def pbSendOut(index,pokemon)
    pbSetSeen(pokemon)
    @peer.pbOnEnteringBattle(self,pokemon)
    if pbIsOpposing?(index)
      @scene.pbTrainerSendOut(index,pokemon)
    else
      @scene.pbSendOut(index,pokemon)
    end
    @scene.pbResetMoveIndex(index)
  end

  def pbReplace(index,newpoke,batonpass=false)
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
      # Reorder the party for this battle
      bpo=-1; bpn=-1
      for i in 0...6
        bpo=i if @partyorder[i]==@battlers[index].pokemonIndex
        bpn=i if @partyorder[i]==newpoke
      end
      poke1=@partyorder[bpo]
      @partyorder[bpo]=@partyorder[bpn]
      @partyorder[bpn]=poke1
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSendOut(index,party[newpoke])
    else
      @battlers[index].pbInitialize(party[newpoke],newpoke,batonpass)
      pbSetSeen(party[newpoke])
      if pbIsOpposing?(index)
        pbSendOut(index,party[newpoke])
      else
        pbSendOut(index,party[newpoke])
      end
    end
  end

  def pbRecallAndReplace(index,newpoke,batonpass=false)
    @battlers[index].pbResetForm
    if !@battlers[index].isFainted?
      @scene.pbRecall(index)
    end
    pbMessagesOnReplace(index,newpoke)
    pbReplace(index,newpoke,batonpass)
    return pbOnActiveOne(@battlers[index])
  end

  def pbMessagesOnReplace(index,newpoke)
    party=pbParty(index)
    if pbOwnedByPlayer?(index)
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
      opposing=@battlers[index].pbOppositeOpposing
      if opposing.isFainted? || opposing.hp==opposing.totalhp
        pbDisplayBrief(_INTL("Go! {1}!",party[newpoke].name))
      elsif opposing.hp>=(opposing.totalhp/2)
        pbDisplayBrief(_INTL("Do it! {1}!",party[newpoke].name))
      elsif opposing.hp>=(opposing.totalhp/4)
        pbDisplayBrief(_INTL("Go for it, {1}!",party[newpoke].name))
      else
        pbDisplayBrief(_INTL("Your foe's weak!\nGet 'em, {1}!",party[newpoke].name))
      end
      PBDebug.log("[Player sent out #{party[newpoke].name}]")
    else
#     if !party[newpoke]
#       p [index,newpoke,party[newpoke],pbAllFainted?(party)]
#       PBDebug.log([index,newpoke,party[newpoke],"pbMOR"].inspect)
#       for i in 0...party.length
#         PBDebug.log([i,party[i].hp].inspect)
#       end
#       raise BattleAbortedException.new
#     end
      owner=pbGetOwner(index)
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",owner.fullname,party[newpoke].name))
      PBDebug.log("[Opponent sent out #{party[newpoke].name}]")
    end
  end

  def pbSwitchInBetween(index,lax,cancancel)
    if !pbOwnedByPlayer?(index)
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return pbSwitchPlayer(index,lax,cancancel)
    end
  end

  def pbSwitchPlayer(index,lax,cancancel)
    if @debug
      return @scene.pbChooseNewEnemy(index,pbParty(index))
    else
      return @scene.pbSwitch(index,lax,cancancel)
    end
  end

################################################################################
# Using an item.
################################################################################
# Uses an item on a Pokémon in the player's party.
  def pbUseItemOnPokemon(item,pkmnIndex,userPkmn,scene)
    pokemon=@party1[pkmnIndex]
    battler=nil
    name=pbGetOwner(userPkmn.index).fullname
    name=pbGetOwner(userPkmn.index).name if pbBelongsToPlayer?(userPkmn.index)
    pbDisplayBrief(_INTL("{1} used the\r\n{2}.",name,PBItems.getName(item)))
    PBDebug.log("[Player used #{PBItems.getName(item)}]")
    ret=false
    if pokemon.isEgg?
      pbDisplay(_INTL("But it had no effect!"))
    else
      for i in 0...4
        if !pbIsOpposing?(i) && @battlers[i].pokemonIndex==pkmnIndex
          battler=@battlers[i]
        end
      end
      ret=ItemHandlers.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
    end
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    end
    return ret
  end

# Uses an item on an active Pokémon.
  def pbUseItemOnBattler(item,index,userPkmn,scene)
    PBDebug.log("[Player used #{PBItems.getName(item)}]")
    ret=ItemHandlers.triggerBattleUseOnBattler(item,@battlers[index],scene)
    if !ret && pbBelongsToPlayer?(userPkmn.index)
      if $PokemonBag.pbCanStore?(item)
        $PokemonBag.pbStoreItem(item)
      else
        raise _INTL("Couldn't return unused item to Bag somehow.")
      end
    end
    return ret
  end

  def pbRegisterItem(idxPokemon,idxItem,idxTarget=nil)
    if ItemHandlers.hasUseInBattle(idxItem)
      if idxPokemon==0 # Player's first Pokémon
        if ItemHandlers.triggerBattleUseOnBattler(idxItem,@battlers[idxPokemon],self)
          ItemHandlers.triggerUseInBattle(idxItem,@battlers[idxPokemon],self)
          if @doublebattle
            @choices[idxPokemon+2][0]=3         # "Use an item"
            @choices[idxPokemon+2][1]=idxItem   # ID of item to be used
            @choices[idxPokemon+2][2]=idxTarget # Index of Pokémon to use item on
          end
        else
          if $PokemonBag.pbCanStore?(idxItem)
            $PokemonBag.pbStoreItem(idxItem)
          else
            raise _INTL("Couldn't return unusable item to Bag somehow.")
          end
          return false
        end
      else
        if ItemHandlers.triggerBattleUseOnBattler(idxItem,@battlers[idxPokemon],self)
          pbDisplay(_INTL("It's impossible to aim without being focused!"))
        end
        return false
      end
    end
    @choices[idxPokemon][0]=3         # "Use an item"
    @choices[idxPokemon][1]=idxItem   # ID of item to be used
    @choices[idxPokemon][2]=idxTarget # Index of Pokémon to use item on
    side=(pbIsOpposing?(idxPokemon)) ? 1 : 0
    owner=pbGetOwnerIndex(idxPokemon)
    if @megaEvolution[side][owner]==idxPokemon
      @megaEvolution[side][owner]=-1
    end
    return true
  end

  def pbEnemyUseItem(item,battler)
    return 0 if !@internalbattle
    items=pbGetOwnerItems(battler.index)
    return if !items
    opponent=pbGetOwner(battler.index)
    for i in 0...items.length
      if items[i]==item
        items.delete_at(i)
        break
      end
    end
    itemname=PBItems.getName(item)
    pbDisplayBrief(_INTL("{1} used the\r\n{2}!",opponent.fullname,itemname))
    PBDebug.log("[Opponent used #{itemname}]")
    if isConst?(item,PBItems,:POTION)
      battler.pbRecoverHP(20,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:SUPERPOTION)
      battler.pbRecoverHP(50,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:HYPERPOTION)
      battler.pbRecoverHP(200,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:MAXPOTION)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
    elsif isConst?(item,PBItems,:FULLRESTORE)
      fullhp=(battler.hp==battler.totalhp)
      battler.pbRecoverHP(battler.totalhp-battler.hp,true)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      if fullhp
        pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
      else
        pbDisplay(_INTL("{1}'s HP was restored.",battler.pbThis))
      end
    elsif isConst?(item,PBItems,:FULLHEAL)
      battler.status=0; battler.statusCount=0
      battler.effects[PBEffects::Confusion]=0
      pbDisplay(_INTL("{1} became healthy!",battler.pbThis))
    elsif isConst?(item,PBItems,:XATTACK)
      if battler.pbCanIncreaseStatStage?(PBStats::ATTACK)
        battler.pbIncreaseStat(PBStats::ATTACK,1,true)
      end
    elsif isConst?(item,PBItems,:XDEFEND)
      if battler.pbCanIncreaseStatStage?(PBStats::DEFENSE)
        battler.pbIncreaseStat(PBStats::DEFENSE,1,true)
      end
    elsif isConst?(item,PBItems,:XSPEED)
      if battler.pbCanIncreaseStatStage?(PBStats::SPEED)
        battler.pbIncreaseStat(PBStats::SPEED,1,true)
      end
    elsif isConst?(item,PBItems,:XSPECIAL)
      if battler.pbCanIncreaseStatStage?(PBStats::SPATK)
        battler.pbIncreaseStat(PBStats::SPATK,1,true)
      end
    elsif isConst?(item,PBItems,:XSPDEF)
      if battler.pbCanIncreaseStatStage?(PBStats::SPDEF)
        battler.pbIncreaseStat(PBStats::SPDEF,1,true)
      end
    elsif isConst?(item,PBItems,:XACCURACY)
      if battler.pbCanIncreaseStatStage?(PBStats::ACCURACY)
        battler.pbIncreaseStat(PBStats::ACCURACY,1,true)
      end
    end
  end

################################################################################
# Fleeing from battle.
################################################################################
  def pbCanRun?(idxPokemon)
    return false if @opponent
    thispkmn=@battlers[idxPokemon]
    return true if thispkmn.hasWorkingItem(:SMOKEBALL)
    return true if thispkmn.hasWorkingAbility(:RUNAWAY)
    return pbCanSwitch?(idxPokemon,-1,false)
  end

  def pbRun(idxPokemon,duringBattle=false)
    thispkmn=@battlers[idxPokemon]
    if pbIsOpposing?(idxPokemon)
      return 0 if @opponent
      @choices[i][0]=5 # run
      @choices[i][1]=0 
      @choices[i][2]=nil
      return -1
    end
    if @opponent
      if $DEBUG && Input.press?(Input::CTRL)
        if pbDisplayConfirm(_INTL("Treat this battle as a win?"))
          @decision=1
          return 1
        elsif pbDisplayConfirm(_INTL("Treat this battle as a loss?"))
          @decision=2
          return 1
        end
      elsif @internalbattle
        pbDisplayPaused(_INTL("No!  There's no running from a Trainer battle!"))
      elsif pbDisplayConfirm(_INTL("Would you like to forfeit the match and quit now?"))
        pbDisplay(_INTL("{1} forfeited the match!",self.pbPlayer.name))
        @decision=3
        return 1
      end
      return 0
    end
    if $DEBUG && Input.press?(Input::CTRL)
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
      return 1
    end
    if @cantescape
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    if thispkmn.hasWorkingItem(:SMOKEBALL)
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using its {2}!",thispkmn.pbThis,PBItems.getName(thispkmn.item)))
      end
      @decision=3
      return 1
    end
    if thispkmn.hasWorkingAbility(:RUNAWAY)
      if duringBattle
        pbDisplayPaused(_INTL("Got away safely!"))
      else
        pbDisplayPaused(_INTL("{1} fled using Run Away!",thispkmn.pbThis))
      end
      @decision=3
      return 1
    end
    if !duringBattle && !pbCanSwitch?(idxPokemon,-1,false) # TODO: Use real messages
      pbDisplayPaused(_INTL("Can't escape!"))
      return 0
    end
    # Note: not pbSpeed, because using unmodified Speed
    speedPlayer=@battlers[idxPokemon].speed
    opposing=@battlers[idxPokemon].pbOppositeOpposing
    opposing=opposing.pbPartner if opposing.isFainted?
    if !opposing.isFainted?
      speedEnemy=opposing.speed
      if speedPlayer>speedEnemy
        rate=256
      else
        speedEnemy=1 if speedEnemy<=0
        rate=speedPlayer*128/speedEnemy
        rate+=@runCommand*30
        rate&=0xFF
      end
    else
      rate=256
    end
    ret=1
    if pbAIRandom(256)<rate
      pbDisplayPaused(_INTL("Got away safely!"))
      @decision=3
    else
      pbDisplayPaused(_INTL("Can't escape!"))
      ret=-1
    end
    @runCommand+=1 if !duringBattle
    return ret
  end

################################################################################
# Mega Evolve battler.
################################################################################
  def pbCanMegaEvolve?(index)
    return false if $game_switches[NO_MEGA_EVOLUTION]
    return false if !@battlers[index].hasMega?
    return false if pbBelongsToPlayer?(index) && !$PokemonGlobal.megaRing
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    return false if @megaEvolution[side][owner]!=-1
    return true
  end

  def pbRegisterMegaEvolution(index)
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=index
  end

  def pbMegaEvolve(index)
    return if !@battlers[index] || !@battlers[index].pokemon
    return if !(@battlers[index].hasMega? rescue false)
    return if (@battlers[index].isMega? rescue true)
    ownername=pbGetOwner(index).fullname
    ownername=pbGetOwner(index).name if pbBelongsToPlayer?(index)
    pbDisplay(_INTL("{1}'s {2} is reacting to {3}'s Mega Ring!",
       @battlers[index].pbThis,
       PBItems.getName(@battlers[index].item),
       ownername))
    pbCommonAnimation("MegaEvolution",@battlers[index],nil)
    @battlers[index].pokemon.makeMega
    @battlers[index].form=@battlers[index].pokemon.form
    @battlers[index].pbUpdate(true)
    @scene.pbChangePokemon(@battlers[index],@battlers[index].pokemon)
    meganame=@battlers[index].pokemon.megaName
    if !meganame || meganame==""
      meganame=_INTL("Mega {1}",PBSpecies.getName(@battlers[index].pokemon.species))
    end
    pbDisplay(_INTL("{1} has Mega Evolved into {2}!",@battlers[index].pbThis,meganame))
    PBDebug.log("[#{@battlers[index].pbThis} Mega Evolved]")
    side=(pbIsOpposing?(index)) ? 1 : 0
    owner=pbGetOwnerIndex(index)
    @megaEvolution[side][owner]=-2
  end

################################################################################
# Call battler.
################################################################################
  def pbCall(index)
    owner=pbGetOwner(index)
    pbDisplay(_INTL("{1} called {2}!",owner.name,@battlers[index].name))
    pbDisplay(_INTL("{1}!",@battlers[index].name))
    PBDebug.log("[#{owner.name} called to #{@battlers[index].pbThis(true)}]")
    if @battlers[index].isShadow?
      if @battlers[index].inHyperMode?
        @battlers[index].pokemon.hypermode=false
        @battlers[index].pokemon.adjustHeart(-300)
        pbDisplay(_INTL("{1} came to its senses from the Trainer's call!",@battlers[index].pbThis))
      else
        pbDisplay(_INTL("But nothing happened!"))
      end
    elsif @battlers[index].status!=PBStatuses::SLEEP &&
          @battlers[index].pbCanIncreaseStatStage?(PBStats::ACCURACY)
      @battlers[index].pbIncreaseStat(PBStats::ACCURACY,1,true)
    else
      pbDisplay(_INTL("But nothing happened!"))
    end
  end

################################################################################
# Gaining Experience.
################################################################################
  def pbGainEXP
    return if !@internalbattle
    successbegin=true
    for i in 0...4 # Not ordered by priority
      if !@doublebattle && pbIsDoubleBattler?(i)
        @battlers[i].participants=[]
        next
      end
      if pbIsOpposing?(i) && @battlers[i].participants.length>0 && @battlers[i].isFainted?
        battlerSpecies=@battlers[i].pokemon.species
        # Original species, not current species
        baseexp=@battlers[i].pokemon.baseExp
        level=@battlers[i].level
        # First count the number of participants
        partic=0
        expshare=0
        for j in @battlers[i].participants
          next if !@party1[j] || !pbIsOwner?(0,j)
          partic+=1 if @party1[j].hp>0 && !@party1[j].isEgg?
        end
        for j in 0...@party1.length
          next if !@party1[j] || !pbIsOwner?(0,j)
          expshare+=1 if @party1[j].hp>0 && !@party1[j].isEgg? && 
             (isConst?(@party1[j].item,PBItems,:EXPSHARE) ||
              isConst?(@party1[j].itemInitial,PBItems,:EXPSHARE))
        end
        # Now calculate EXP for the participants
        if partic>0 || expshare>0
          if !@opponent && successbegin && pbAllFainted?(@party2)
            @scene.pbWildBattleSuccess
            successbegin=false
          end
          for j in 0...@party1.length
            thispoke=@party1[j]
            next if !@party1[j] || !pbIsOwner?(0,j)
            ispartic=0
            haveexpshare=(isConst?(thispoke.item,PBItems,:EXPSHARE) ||
                          isConst?(thispoke.itemInitial,PBItems,:EXPSHARE)) ? 1 : 0
            for k in @battlers[i].participants
              ispartic=1 if k==j
            end
            if thispoke.hp>0 && !thispoke.isEgg?
              exp=0
              if expshare>0
                if partic==0
                  exp=(level*baseexp).floor
                  exp=(exp/expshare).floor*haveexpshare
                else
                  exp=(level*baseexp/2).floor
                  exp=(exp/partic).floor*ispartic + (exp/expshare).floor*haveexpshare
                end
              elsif ispartic==1
                exp=(level*baseexp/partic).floor
              end
              exp=(exp*3/2).floor if @opponent
              if USENEWEXPFORMULA   # Use new (Gen 5) Exp. formula
                exp=(exp/5).floor
                leveladjust=(2*level+10.0)/(level+thispoke.level+10.0)
                leveladjust=leveladjust**5
                leveladjust=Math.sqrt(leveladjust)
                exp=(exp*leveladjust).floor
                exp+=1 if ispartic>0 || haveexpshare>0
              else                  # Use old (Gen 1-4) Exp. formula
                exp=(exp/7).floor
              end
              isOutsider=(thispoke.trainerID!=self.pbPlayer.id ||
                 (thispoke.language!=0 && thispoke.language!=self.pbPlayer.language))
              if isOutsider
                if thispoke.language!=0 && thispoke.language!=self.pbPlayer.language
                  exp=(exp*17/10).floor
                else
                  exp=(exp*3/2).floor
                end
              end
              exp=(exp*3/2).floor if isConst?(thispoke.item,PBItems,:LUCKYEGG) ||
                                     isConst?(thispoke.itemInitial,PBItems,:LUCKYEGG)
              growthrate=thispoke.growthrate
              newexp=PBExperience.pbAddExperience(thispoke.exp,exp,growthrate)
              exp=newexp-thispoke.exp
              if exp > 0
                if isOutsider
                  pbDisplayPaused(_INTL("{1} gained a boosted {2} Exp. Points!",thispoke.name,exp))
                else
                  pbDisplayPaused(_INTL("{1} gained {2} Exp. Points!",thispoke.name,exp))
                end
                #Gain effort value points, using RS effort values
                totalev=0
                for k in 0..5
                  totalev+=thispoke.ev[k]
                end
                # Original species, not current species
                evyield=@battlers[i].pokemon.evYield
                for k in 0..5
                  evgain=evyield[k]
                  evgain*=2 if isConst?(thispoke.item,PBItems,:MACHOBRACE) ||
                               isConst?(thispoke.itemInitial,PBItems,:MACHOBRACE)
                  evgain+=4 if k==0 && isConst?(thispoke.item,PBItems,:POWERWEIGHT) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERWEIGHT)
                  evgain+=4 if k==1 && isConst?(thispoke.item,PBItems,:POWERBRACER) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBRACER)
                  evgain+=4 if k==2 && isConst?(thispoke.item,PBItems,:POWERBELT) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBELT)
                  evgain+=4 if k==3 && isConst?(thispoke.item,PBItems,:POWERANKLET) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERANKLET)
                  evgain+=4 if k==4 && isConst?(thispoke.item,PBItems,:POWERLENS) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERLENS)
                  evgain+=4 if k==5 && isConst?(thispoke.item,PBItems,:POWERBAND) ||
                                       isConst?(thispoke.itemInitial,PBItems,:POWERBAND)
                  evgain*=2 if thispoke.pokerusStage>=1 # Infected or cured
                  if evgain>0
                    # Can't exceed overall limit
                    if totalev+evgain>510
                      evgain-=totalev+evgain-510
                    end
                    # Can't exceed stat limit
                    if thispoke.ev[k]+evgain>255
                      evgain-=thispoke.ev[k]+evgain-255
                    end
                    # Add EV gain
                    thispoke.ev[k]+=evgain
                    if thispoke.ev[k]>255
                      print "Single-stat EV limit 255 exceeded.\r\nStat: #{k}  EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                      thispoke.ev[k]=255
                    end
                    totalev+=evgain
                    if totalev>510
                      print "EV limit 510 exceeded.\r\nTotal EVs: #{totalev} EV gain: #{evgain}  EVs: #{thispoke.ev.inspect}"
                    end
                  end
                end
                newlevel=PBExperience.pbGetLevelFromExperience(newexp,growthrate)
                tempexp=0
                curlevel=thispoke.level
                thisPokeSpecies=thispoke.species
                if newlevel<curlevel
                  debuginfo="#{thispoke.name}: #{thispoke.level}/#{newlevel} | #{thispoke.exp}/#{newexp} | gain: #{exp}"
                  raise RuntimeError.new(
                     _INTL("The new level ({1}) is less than the Pokémon's\r\ncurrent level ({2}), which shouldn't happen.\r\n[Debug: {3}]",
                     newlevel,curlevel,debuginfo))
                  return
                end
                if thispoke.respond_to?("isShadow?") && thispoke.isShadow?
                  thispoke.exp+=exp
                else
                  tempexp1=thispoke.exp
                  tempexp2=0
                  # Find battler
                  battler=pbFindPlayerBattler(j)
                  loop do
                    #EXP Bar animation
                    startexp=PBExperience.pbGetStartExperience(curlevel,growthrate)
                    endexp=PBExperience.pbGetStartExperience(curlevel+1,growthrate)
                    tempexp2=(endexp<newexp) ? endexp : newexp
                    thispoke.exp=tempexp2
                    @scene.pbEXPBar(thispoke,battler,startexp,endexp,tempexp1,tempexp2)
                    tempexp1=tempexp2
                    curlevel+=1
                    if curlevel>newlevel
                      thispoke.calcStats 
                      battler.pbUpdate(false) if battler
                      @scene.pbRefresh
                      break
                    end
                    oldtotalhp=thispoke.totalhp
                    oldattack=thispoke.attack
                    olddefense=thispoke.defense
                    oldspeed=thispoke.speed
                    oldspatk=thispoke.spatk
                    oldspdef=thispoke.spdef
                    if battler
                      if battler.pokemon && @internalbattle
                        battler.pokemon.changeHappiness("level up")
                      end
                    end
                    thispoke.calcStats
                    battler.pbUpdate(false) if battler
                    @scene.pbRefresh
                    pbDisplayPaused(_INTL("{1} grew to Level {2}!",thispoke.name,curlevel))
                    @scene.pbLevelUp(thispoke,battler,oldtotalhp,oldattack,
                       olddefense,oldspeed,oldspatk,oldspdef)
                    # Finding all moves learned at this level
                    movelist=thispoke.getMoveList
                    for k in movelist
                      if k[0]==thispoke.level   # Learned a new move
                        pbLearnMove(j,k[1])
                      end
                    end
                  end
                end
              end
            end
          end
        end
        # Now clear the participants array
        @battlers[i].participants=[]
      end
    end
  end

################################################################################
# Learning a move.
################################################################################
  def pbLearnMove(pkmnIndex,move)
    pokemon=@party1[pkmnIndex]
    return if !pokemon
    pkmnname=pokemon.name
    battler=pbFindPlayerBattler(pkmnIndex)
    movename=PBMoves.getName(move)
    for i in 0...4
      return if pokemon.moves[i].id==move
      if pokemon.moves[i].id==0
        pokemon.moves[i]=PBMove.new(move)
        battler.moves[i]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[i]) if battler
        pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
        PBDebug.log("[#{pkmnname} learned #{movename}]")
        return
      end
    end
    loop do
      pbDisplayPaused(_INTL("{1} is trying to learn {2}.",pkmnname,movename))
      pbDisplayPaused(_INTL("But {1} can't learn more than four moves.",pkmnname))
      if pbDisplayConfirm(_INTL("Delete a move to make room for {1}?",movename))
        pbDisplayPaused(_INTL("Which move should be forgotten?"))
        forgetmove=@scene.pbForgetMove(pokemon,move)
        if forgetmove>=0
          oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
          pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
          battler.moves[forgetmove]=PokeBattle_Move.pbFromPBMove(self,pokemon.moves[forgetmove]) if battler
          pbDisplayPaused(_INTL("1,  2, and... ... ..."))
          pbDisplayPaused(_INTL("Poof!"))
          pbDisplayPaused(_INTL("{1} forgot {2}.",pkmnname,oldmovename))
          pbDisplayPaused(_INTL("And..."))
          pbDisplayPaused(_INTL("{1} learned {2}!",pkmnname,movename))
          PBDebug.log("[#{pkmnname} forgot #{oldmovename} and learned #{movename}]")
          return
        elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
          pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
          return
        end
      elsif pbDisplayConfirm(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        pbDisplayPaused(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return
      end
    end
  end

################################################################################
# Abilities.
################################################################################
  def pbOnActiveAll
    for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
      @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
      @amuletcoin=true if !pbIsOpposing?(i) &&
                          (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                           isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
    end
    for i in 0...4
      if !@battlers[i].isFainted?
        if @battlers[i].isShadow? && pbIsOpposing?(i)
          pbCommonAnimation("Shadow",@battlers[i],nil)
          pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
        end
      end
    end
    # Weather-inducing abilities, Trace, Imposter, etc.
    @usepriority=false
    priority=pbPriority
    for i in priority
      i.pbAbilitiesOnSwitchIn(true)
    end
    # Check forms are correct
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
    end
  end

  def pbOnActiveOne(pkmn,onlyabilities=false)
    return false if pkmn.isFainted?
    if !onlyabilities
      for i in 0...4 # Currently unfainted participants will earn EXP even if they faint afterwards
        @battlers[i].pbUpdateParticipants if pbIsOpposing?(i)
        @amuletcoin=true if !pbIsOpposing?(i) &&
                            (isConst?(@battlers[i].item,PBItems,:AMULETCOIN) ||
                             isConst?(@battlers[i].item,PBItems,:LUCKINCENSE))
      end
      if pkmn.isShadow? && pbIsOpposing?(pkmn.index)
        pbCommonAnimation("Shadow",pkmn,nil)
        pbDisplay(_INTL("Oh!\nA Shadow Pokemon!"))
      end
      # Healing Wish
      if pkmn.effects[PBEffects::HealingWish]
        PBDebug.log("[#{pkmn.pbThis}'s Healing Wish triggered]")
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        pbDisplayPaused(_INTL("The healing wish came true for {1}!",pkmn.pbThis(true)))
        pkmn.effects[PBEffects::HealingWish]=false
      end
      # Lunar Dance
      if pkmn.effects[PBEffects::LunarDance]
        PBDebug.log("[#{pkmn.pbThis}'s Lunar Dance triggered]")
        pkmn.pbRecoverHP(pkmn.totalhp,true)
        pkmn.status=0
        pkmn.statusCount=0
        for i in 0...4
          pkmn.moves[i].pp=pkmn.moves[i].totalpp
        end
        pbDisplayPaused(_INTL("{1} became cloaked in mystical moonlight!",pkmn.pbThis))
        pkmn.effects[PBEffects::LunarDance]=false
      end
      # Spikes
      if pkmn.pbOwnSide.effects[PBEffects::Spikes]>0
        if !pkmn.isAirborne?
          if !pkmn.hasWorkingAbility(:MAGICGUARD)
            PBDebug.log("[#{pkmn.pbThis} took damage from Spikes]")
            spikesdiv=[8,8,6,4][pkmn.pbOwnSide.effects[PBEffects::Spikes]]
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp/spikesdiv).floor,1].max)
            pbDisplayPaused(_INTL("{1} was hurt by spikes!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.isFainted?
      # Stealth Rock
      if pkmn.pbOwnSide.effects[PBEffects::StealthRock]
        if !pkmn.hasWorkingAbility(:MAGICGUARD)
          atype=getConst(PBTypes,:ROCK) || 0
          eff=PBTypes.getCombinedEffectiveness(atype,pkmn.type1,pkmn.type2)
          if eff>0
            PBDebug.log("[#{pkmn.pbThis} took damage from Stealth Rock]")
            @scene.pbDamageAnimation(pkmn,0)
            pkmn.pbReduceHP([(pkmn.totalhp*eff/32).floor,1].max)
            pbDisplayPaused(_INTL("{1} was hurt by stealth rocks!",pkmn.pbThis))
          end
        end
      end
      pkmn.pbFaint if pkmn.isFainted?
      # Toxic Spikes
      if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]>0
        if !pkmn.isAirborne?
          if pkmn.pbHasType?(:POISON)
            PBDebug.log("[#{pkmn.pbThis} absorbed Toxic Spikes]")
            pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]=0
            pbDisplayPaused(_INTL("{1} absorbed the poison spikes!",pkmn.pbThis))
          elsif pkmn.pbCanPoisonSpikes?
            PBDebug.log("[#{pkmn.pbThis} was affected by Toxic Spikes]")
            if pkmn.pbOwnSide.effects[PBEffects::ToxicSpikes]==2
              pkmn.pbPoison(pkmn,true)
              pbDisplayPaused(_INTL("{1} was badly poisoned!",pkmn.pbThis))
            else
              pkmn.pbPoison(pkmn)
              pbDisplayPaused(_INTL("{1} was poisoned!",pkmn.pbThis))
            end
          end
        end
      end
    end
    pkmn.pbAbilityCureCheck
    if pkmn.isFainted?
      pbGainEXP
      pbJudge #      pbSwitch
      return false
    end
#    pkmn.pbAbilitiesOnSwitchIn(true)
    if !onlyabilities
      pkmn.pbCheckForm
      pkmn.pbBerryCureCheck
    end
    return true
  end

################################################################################
# Judging.
################################################################################
  def pbJudgeCheckpoint(attacker,move=0)
  end

  def pbDecisionOnTime
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.isEgg?
        count1+=1
        hptotal1+=i.hp
      end
    end
    for i in @party2
      next if !i
      if i.hp>0 && !i.isEgg?
        count2+=1
        hptotal2+=i.hp
      end
    end
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnTime2
    count1=0
    count2=0
    hptotal1=0
    hptotal2=0
    for i in @party1
      next if !i
      if i.hp>0 && !i.isEgg?
        count1+=1
        hptotal1+=(i.hp*100/i.totalhp)
      end
    end
    hptotal1/=count1 if count1>0
    for i in @party2
      next if !i
      if i.hp>0 && !i.isEgg?
        count2+=1
        hptotal2+=(i.hp*100/i.totalhp)
      end
    end
    hptotal2/=count2 if count2>0
    return 1 if count1>count2     # win
    return 2 if count1<count2     # loss
    return 1 if hptotal1>hptotal2 # win
    return 2 if hptotal1<hptotal2 # loss
    return 5                      # draw
  end

  def pbDecisionOnDraw
    return 5 # draw
  end

  def pbJudge
#   PBDebug.log("[Counts: #{pbPokemonCount(@party1)}/#{pbPokemonCount(@party2)}]")
    if pbAllFainted?(@party1) && pbAllFainted?(@party2)
      @decision=pbDecisionOnDraw() # Draw
      return
    end
    if pbAllFainted?(@party1)
      @decision=2 # Loss
      return
    end
    if pbAllFainted?(@party2)
      @decision=1 # Win
      return
    end
  end

################################################################################
# Messages and animations.
################################################################################
  def pbDisplay(msg)
    @scene.pbDisplayMessage(msg)
  end

  def pbDisplayPaused(msg)
    @scene.pbDisplayPausedMessage(msg)
  end

  def pbDisplayBrief(msg)
    @scene.pbDisplayMessage(msg,true)
  end

  def pbDisplayConfirm(msg)
    @scene.pbDisplayConfirmMessage(msg)
  end

  def pbShowCommands(msg,commands,cancancel=true)
    @scene.pbShowCommands(msg,commands,cancancel)
  end

  def pbAnimation(move,attacker,opponent,hitnum=0)
    if @battlescene
      @scene.pbAnimation(move,attacker,opponent,hitnum)
    end
  end

  def pbCommonAnimation(name,attacker,opponent,hitnum=0)
    if @battlescene
      @scene.pbCommonAnimation(name,attacker,opponent,hitnum)
    end
  end

################################################################################
# Battle core.
################################################################################
  def pbStartBattle(canlose=false)
    PBDebug.log("******************************************")
    begin
      pbStartBattleCore(canlose)
    rescue BattleAbortedException
      @decision=0
      @scene.pbEndBattle(@decision)
    end
    return @decision
  end

  def pbStartBattleCore(canlose)
    if !@fullparty1 && @party1.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 1 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
    if !@fullparty2 && @party2.length>MAXPARTYSIZE
      raise ArgumentError.new(_INTL("Party 2 has more than {1} Pokémon.",MAXPARTYSIZE))
    end
#========================
# Initialize wild Pokémon
#========================
    if !@opponent
      if @party2.length==1
        if @doublebattle
          raise _INTL("Only two wild Pokémon are allowed in double battles")
        end
        wildpoke=@party2[0]
        @battlers[1].pbInitialize(wildpoke,0,false)
        @peer.pbOnEnteringBattle(self,wildpoke)
        pbSetSeen(wildpoke)
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} appeared!",wildpoke.name))
      elsif @party2.length==2
        if !@doublebattle
          raise _INTL("Only one wild Pokémon is allowed in single battles")
        end
        @battlers[1].pbInitialize(@party2[0],0,false)
        @battlers[3].pbInitialize(@party2[1],0,false)
        @peer.pbOnEnteringBattle(self,@party2[0])
        @peer.pbOnEnteringBattle(self,@party2[1])
        pbSetSeen(@party2[0])
        pbSetSeen(@party2[1])
        @scene.pbStartBattle(self)
        pbDisplayPaused(_INTL("Wild {1} and\r\n{2} appeared!",
           @party2[0].name,@party2[1].name))
      else
        raise _INTL("Only one or two wild Pokémon are allowed")
      end
#=======================================
# Initialize opponents in double battles
#=======================================
    elsif @doublebattle
      if @opponent.is_a?(Array)
        if @opponent.length==1
          @opponent=@opponent[0]
        elsif @opponent.length!=2
          raise _INTL("Opponents with zero or more than two people are not allowed")
        end
      end
      if @player.is_a?(Array)
        if @player.length==1
          @player=@player[0]
        elsif @player.length!=2
          raise _INTL("Player trainers with zero or more than two people are not allowed")
        end
      end
      @scene.pbStartBattle(self)
      if @opponent.is_a?(Array)
        pbDisplayPaused(_INTL("{1} and {2} want to battle!",@opponent[0].fullname,@opponent[1].fullname))
        sendout1=pbFindNextUnfainted(@party2,0,pbSecondPartyBegin(1))
        raise _INTL("Opponent 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party2,pbSecondPartyBegin(1))
        raise _INTL("Opponent 2 has no unfainted Pokémon") if sendout2<0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[0].fullname,@party2[sendout1].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent[1].fullname,@party2[sendout2].name))
        pbSendOut(3,@party2[sendout2])
      else
        pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
        sendout1=pbFindNextUnfainted(@party2,0)
        sendout2=pbFindNextUnfainted(@party2,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Opponent doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("{1} sent\r\nout {2} and {3}!",
           @opponent.fullname,@party2[sendout1].name,@party2[sendout2].name))
        @battlers[1].pbInitialize(@party2[sendout1],sendout1,false)
        @battlers[3].pbInitialize(@party2[sendout2],sendout2,false)
        pbSendOut(1,@party2[sendout1])
        pbSendOut(3,@party2[sendout2])
      end
#======================================
# Initialize opponent in single battles
#======================================
    else
      sendout=pbFindNextUnfainted(@party2,0)
      raise _INTL("Trainer has no unfainted Pokémon") if sendout<0
      if @opponent.is_a?(Array)
        raise _INTL("Opponent trainer must be only one person in single battles") if @opponent.length!=1
        @opponent=@opponent[0]
      end
      if @player.is_a?(Array)
        raise _INTL("Player trainer must be only one person in single battles") if @player.length!=1
        @player=@player[0]
      end
      trainerpoke=@party2[sendout]
      @scene.pbStartBattle(self)
      pbDisplayPaused(_INTL("{1}\r\nwould like to battle!",@opponent.fullname))
      pbDisplayBrief(_INTL("{1} sent\r\nout {2}!",@opponent.fullname,trainerpoke.name))
      @battlers[1].pbInitialize(trainerpoke,sendout,false)
      pbSendOut(1,trainerpoke)
    end
#=====================================
# Initialize players in double battles
#=====================================
    if @doublebattle
      if @player.is_a?(Array)
        sendout1=pbFindNextUnfainted(@party1,0,pbSecondPartyBegin(0))
        raise _INTL("Player 1 has no unfainted Pokémon") if sendout1<0
        sendout2=pbFindNextUnfainted(@party1,pbSecondPartyBegin(0))
        raise _INTL("Player 2 has no unfainted Pokémon") if sendout2<0
        pbDisplayBrief(_INTL("{1} sent\r\nout {2}!  Go! {3}!",
           @player[1].fullname,@party1[sendout2].name,@party1[sendout1].name))
        pbSetSeen(@party1[sendout1])
        pbSetSeen(@party1[sendout2])
      else
        sendout1=pbFindNextUnfainted(@party1,0)
        sendout2=pbFindNextUnfainted(@party1,sendout1+1)
        if sendout1<0 || sendout2<0
          raise _INTL("Player doesn't have two unfainted Pokémon")
        end
        pbDisplayBrief(_INTL("Go! {1} and {2}!",@party1[sendout1].name,@party1[sendout2].name))
      end
      @battlers[0].pbInitialize(@party1[sendout1],sendout1,false)
      @battlers[2].pbInitialize(@party1[sendout2],sendout2,false)
      pbSendOut(0,@party1[sendout1])
      pbSendOut(2,@party1[sendout2])
#====================================
# Initialize player in single battles
#====================================
    else
      sendout=pbFindNextUnfainted(@party1,0)
      if sendout<0
        raise _INTL("Player has no unfainted Pokémon")
      end
      playerpoke=@party1[sendout]
      pbDisplayBrief(_INTL("Go! {1}!",playerpoke.name))
      @battlers[0].pbInitialize(playerpoke,sendout,false)
      pbSendOut(0,playerpoke)
    end
#==================
# Initialize battle
#==================
    if @weather==PBWeather::SUNNYDAY
      pbCommonAnimation("Sunny",nil,nil)
      pbDisplay(_INTL("The sunlight is strong."))
    elsif @weather==PBWeather::RAINDANCE
      pbCommonAnimation("Rain",nil,nil)
      pbDisplay(_INTL("It is raining."))
    elsif @weather==PBWeather::SANDSTORM
      pbCommonAnimation("Sandstorm",nil,nil)
      pbDisplay(_INTL("A sandstorm is raging."))
    elsif @weather==PBWeather::HAIL
      pbCommonAnimation("Hail",nil,nil)
      pbDisplay(_INTL("Hail is falling."))
    end
    pbOnActiveAll   # Abilities
    @turncount=0
    loop do   # Now begin the battle loop
      PBDebug.log("***Round #{@turncount+1}***")
      if @debug && @turncount>=100
        @decision=pbDecisionOnTime()
        PBDebug.log("***Undecided after 100 rounds, aborting***")
        pbAbort
        break
      end
      PBDebug.logonerr{
         pbCommandPhase
      }
      break if @decision>0
      PBDebug.logonerr{
         pbAttackPhase
      }
      break if @decision>0
      PBDebug.logonerr{
         pbEndOfRoundPhase
      }
      break if @decision>0
      @turncount+=1
    end
    return pbEndOfBattle(canlose)
  end

################################################################################
# Command phase.
################################################################################
  def pbCommandMenu(i)
    return @scene.pbCommandMenu(i)
  end

  def pbItemMenu(i)
    return @scene.pbItemMenu(i)
  end

  def pbAutoFightMenu(i)
    return false
  end

  def pbCommandPhase
    @scene.pbBeginCommandPhase
    @scene.pbResetCommandIndices
    for i in 0...4   # Reset choices if commands can be shown
      if pbCanShowCommands?(i) || @battlers[i].isFainted?
        @choices[i][0]=0
        @choices[i][1]=0
        @choices[i][2]=nil
        @choices[i][3]=-1
      else
        battler=@battlers[i]
        unless !@doublebattle && pbIsDoubleBattler?(i)
          PBDebug.log("[Reusing commands for #{battler.pbThis(true)}]")
        end
      end
    end
    # Reset choices to perform Mega Evolution if it wasn't done somehow
    for i in 0..1
      for j in 0...@megaEvolution[i].length
        @megaEvolution[i][j]=-1 if @megaEvolution[i][j]>=0
      end
    end
    for i in 0...4
      break if @decision!=0
      next if @choices[i][0]!=0
      if !pbOwnedByPlayer?(i) || @controlPlayer
        if !@battlers[i].isFainted? && pbCanShowCommands?(i)
          @scene.pbChooseEnemyCommand(i)
        end
      else
        commandDone=false
        commandEnd=false
        if pbCanShowCommands?(i)
          loop do
            cmd=pbCommandMenu(i)
            if cmd==0 # Fight
              if pbCanShowFightMenu?(i)
                commandDone=true if pbAutoFightMenu(i)
                until commandDone
                  index=@scene.pbFightMenu(i)
                  if index<0
                    side=(pbIsOpposing?(i)) ? 1 : 0
                    owner=pbGetOwnerIndex(i)
                    if @megaEvolution[side][owner]==i
                      @megaEvolution[side][owner]=-1
                    end
                    break
                  end
                  next if !pbRegisterMove(i,index)
                  if @doublebattle
                    thismove=@battlers[i].moves[index]
                    target=@battlers[i].pbTarget(thismove)
                    if target==PBTargets::SingleNonUser # single non-user
                      target=@scene.pbChooseTarget(i)
                      next if target<0
                      pbRegisterTarget(i,target)
                    elsif target==PBTargets::UserOrPartner # Acupressure
                      target=@scene.pbChooseTarget(i)
                      next if target<0 || (target&1)==1
                      pbRegisterTarget(i,target)
                    end
                  end
                  commandDone=true
                end
              else
                pbAutoChooseMove(i)
                commandDone=true
              end
            elsif cmd==1 # Bag
              if !@internalbattle
                if pbOwnedByPlayer?(i)
                  pbDisplay(_INTL("Items can't be used here."))
                end
              else
                item=pbItemMenu(i)
                if item[0]>0
                  if pbRegisterItem(i,item[0],item[1])
                    commandDone=true
                  end
                end
              end
            elsif cmd==2 # Pokémon
              pkmn=pbSwitchPlayer(i,false,true)
              if pkmn>=0
                commandDone=true if pbRegisterSwitch(i,pkmn)
              end
            elsif cmd==3   # Run
              run=pbRun(i) 
              if run>0
                commandDone=true
                return
              elsif run<0
                commandDone=true
                side=(pbIsOpposing?(i)) ? 1 : 0
                owner=pbGetOwnerIndex(i)
                if @megaEvolution[side][owner]==i
                  @megaEvolution[side][owner]=-1
                end
              end
            elsif cmd==4   # Call
              thispkmn=@battlers[i]
              @choices[i][0]=4   # "Call Pokémon"
              @choices[i][1]=0
              @choices[i][2]=nil
              side=(pbIsOpposing?(i)) ? 1 : 0
              owner=pbGetOwnerIndex(i)
              if @megaEvolution[side][owner]==i
                @megaEvolution[side][owner]=-1
              end
              commandDone=true
            elsif cmd==-1   # Go back to first battler's choice
              @megaEvolution[0][0]=-1 if @megaEvolution[0][0]>=0
              @megaEvolution[1][0]=-1 if @megaEvolution[1][0]>=0
              # Restore the item the player's first Pokémon was due to use
              if @choices[0][0]==3 && $PokemonBag && $PokemonBag.pbCanStore?(@choices[0][1])
                $PokemonBag.pbStoreItem(@choices[0][1])
              end
              pbCommandPhase
              return
            end
            break if commandDone
          end
        end
      end
    end
  end

################################################################################
# Attack phase.
################################################################################
  def pbAttackPhase
    @scene.pbBeginAttackPhase
    for i in 0...4
      @successStates[i].clear
      if @choices[i][0]!=1 && @choices[i][0]!=2
        @battlers[i].effects[PBEffects::DestinyBond]=false
        @battlers[i].effects[PBEffects::Grudge]=false
      end
      @battlers[i].turncount+=1 if !@battlers[i].isFainted?
      @battlers[i].effects[PBEffects::Rage]=false if !pbChoseMove?(i,:RAGE)
    end
    # Calculate priority at this time
    @usepriority=false
    priority=pbPriority
    # Mega Evolution
    for i in priority
      next if @choices[i.index][0]!=1
      side=(pbIsOpposing?(i.index)) ? 1 : 0
      owner=pbGetOwnerIndex(i.index)
      if @megaEvolution[side][owner]==i.index
        pbMegaEvolve(i.index)
      end
    end
    # Call at Pokémon
    for i in priority
      if @choices[i.index][0]==4
        pbCall(i.index)
      end
    end
    # Switch out Pokémon
    @switching=true
    switched=[]
    for i in priority
      if @choices[i.index][0]==2
        index=@choices[i.index][1] # party position of Pokémon to switch to
        self.lastMoveUser=i.index
        if !pbOwnedByPlayer?(i.index)
          owner=pbGetOwner(i.index)
          pbDisplayBrief(_INTL("{1} withdrew {2}!",owner.fullname,i.name))
          PBDebug.log("[Opponent withdrew #{i.pbThis(true)}]")
        else
          pbDisplayBrief(_INTL("{1}, that's enough!\r\nCome back!",i.name))
          PBDebug.log("[Player withdrew #{i.pbThis(true)}]")
        end
        for j in priority
          next if !i.pbIsOpposing?(j.index)
          # if Pursuit and this target ("i") was chosen
          if pbChoseMoveFunctionCode?(j.index,0x88) &&
             !j.effects[PBEffects::Pursuit] &&
             (@choices[j.index][3]==-1 || @choices[j.index][3]==i.index)
            if j.status!=PBStatuses::SLEEP &&
               j.status!=PBStatuses::FROZEN &&
               (!j.hasWorkingAbility(:TRUANT) || !j.effects[PBEffects::Truant])
              j.pbUseMove(@choices[j.index])
              j.effects[PBEffects::Pursuit]=true
              # UseMove calls pbGainEXP as appropriate
              @switching=false
              return if @decision>0
            end
          end
          break if i.isFainted?
        end
        if !pbRecallAndReplace(i.index,index)
          # If a forced switch somehow occurs here in single battles
          # the attack phase now ends
          if !@doublebattle
            @switching=false
            return
          end
        else
          switched.push(i.index)
        end
      end
    end
    if switched.length>0
      for i in priority
        i.pbAbilitiesOnSwitchIn(true) if switched.include?(i.index)
      end
    end
    @switching=false
    # Use items
    for i in priority
      if pbIsOpposing?(i.index) && @choices[i.index][0]==3
        pbEnemyUseItem(@choices[i.index][1],i)
      elsif @choices[i.index][0]==3
        # Player use item
        item=@choices[i.index][1]
        if item>0
          usetype=$ItemData[item][ITEMBATTLEUSE]
          if usetype==1 || usetype==3
            if @choices[i.index][2]>=0
              pbUseItemOnPokemon(item,@choices[i.index][2],i,@scene)
            end
          elsif usetype==2 || usetype==4
            if !ItemHandlers.hasUseInBattle(item) # Poké Ball/Poké Doll used already
              pbUseItemOnBattler(item,@choices[i.index][2],i,@scene)
            end
          end
        end
      end
    end
    # Use attacks
    for i in priority
      if pbChoseMoveFunctionCode?(i.index,0x115) # Focus Punch
        pbCommonAnimation("FocusPunch",i,nil)
        pbDisplay(_INTL("{1} is tightening its focus!",i.pbThis))
      end
    end
    for i in priority
      i.pbProcessTurn(@choices[i.index])
      return if @decision>0
    end
    pbWait(20)
  end

################################################################################
# End of round.
################################################################################
  def pbEndOfRoundPhase
    for i in 0...4
      @battlers[i].effects[PBEffects::Roost]=false
      @battlers[i].effects[PBEffects::Protect]=false
      @battlers[i].effects[PBEffects::ProtectNegation]=false
      @battlers[i].effects[PBEffects::Endure]=false
      @battlers[i].effects[PBEffects::HyperBeam]-=1 if @battlers[i].effects[PBEffects::HyperBeam]>0
    end
    @usepriority=false  # recalculate priority
    priority=pbPriority(true) # Ignoring Quick Claw here
    # Weather
    case @weather
    when PBWeather::SUNNYDAY
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The sunlight faded."))
        @weather=0
        PBDebug.log("[Sunlight weather ended]")
      else
        pbCommonAnimation("Sunny",nil,nil)
#        pbDisplay(_INTL("The sunlight is strong."));
        for i in priority
          if i.hasWorkingAbility(:SOLARPOWER)
            PBDebug.log("[#{i.pbThis}'s Solar Power triggered]")
            @scene.pbDamageAnimation(i,0)
            i.pbReduceHP((i.totalhp/8).floor)
            pbDisplay(_INTL("{1} was hurt by the sunlight!",i.pbThis))
            if i.isFainted?
              return if !i.pbFaint
            end
          end
        end
      end
    when PBWeather::RAINDANCE
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The rain stopped."))
        @weather=0
        PBDebug.log("[Rain weather ended]")
      else
        pbCommonAnimation("Rain",nil,nil)
#        pbDisplay(_INTL("Rain continues to fall."));
      end
    when PBWeather::SANDSTORM
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The sandstorm subsided."))
        @weather=0
        PBDebug.log("[Sandstorm weather ended]")
      else
        pbCommonAnimation("Sandstorm",nil,nil)
#        pbDisplay(_INTL("The sandstorm rages."))
        if pbWeather==PBWeather::SANDSTORM
          PBDebug.log("[Sandstorm weather inflicted damage]")
          for i in priority
            next if i.isFainted?
            if !i.pbHasType?(:GROUND) && !i.pbHasType?(:ROCK) && !i.pbHasType?(:STEEL) &&
               !i.hasWorkingAbility(:SANDVEIL) &&
               !i.hasWorkingAbility(:SANDRUSH) &&
               !i.hasWorkingAbility(:SANDFORCE) &&
               !i.hasWorkingAbility(:MAGICGUARD) &&
               !i.hasWorkingAbility(:OVERCOAT) &&
               ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16).floor)
              pbDisplay(_INTL("{1} is buffeted by the sandstorm!",i.pbThis))
              if i.isFainted?
                return if !i.pbFaint
              end
            end
          end
        end
      end
    when PBWeather::HAIL
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The hail stopped."))
        @weather=0
        PBDebug.log("[Hail weather ended]")
      else
        pbCommonAnimation("Hail",nil,nil)
#        pbDisplay(_INTL("Hail continues to fall."))
        if pbWeather==PBWeather::HAIL
          PBDebug.log("[Hail weather inflicted damage]")
          for i in priority
            next if i.isFainted?
            if !i.pbHasType?(:ICE) &&
               !i.hasWorkingAbility(:ICEBODY) &&
               !i.hasWorkingAbility(:SNOWCLOAK) &&
               !i.hasWorkingAbility(:MAGICGUARD) &&
               !i.hasWorkingAbility(:OVERCOAT) &&
               ![0xCA,0xCB].include?(PBMoveData.new(i.effects[PBEffects::TwoTurnAttack]).function) # Dig, Dive
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16).floor)
              pbDisplay(_INTL("{1} is buffeted by the hail!",i.pbThis))
              if i.isFainted?
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    # Shadow Sky weather
    if isConst?(@weather,PBWeather,:SHADOWSKY)
      @weatherduration=@weatherduration-1 if @weatherduration>0
      if @weatherduration==0
        pbDisplay(_INTL("The shadow sky faded."))
        @weather=0
        PBDebug.log("[Shadow Sky weather ended]")
      else
        pbCommonAnimation("ShadowSky",nil,nil)
#        pbDisplay(_INTL("The shadow sky continues."));
        if isConst?(pbWeather,PBWeather,:SHADOWSKY)
          PBDebug.log("[Shadow Sky weather inflicted damage]")
          for i in priority
            next if i.isFainted?
            if !i.isShadow?
              @scene.pbDamageAnimation(i,0)
              i.pbReduceHP((i.totalhp/16).floor)
              pbDisplay(_INTL("{1} was hurt by the shadow sky!",i.pbThis))
              if i.isFainted?
                return if !i.pbFaint
              end
            end
          end
        end
      end
    end
    # Future Sight/Doom Desire
    for i in battlers   # not priority
      next if i.isFainted?
      if i.effects[PBEffects::FutureSight]>0
        i.effects[PBEffects::FutureSight]-=1
        if i.effects[PBEffects::FutureSight]==0
          PBDebug.log("[Future Sight struck #{i.pbThis(true)}]")
          move=PokeBattle_Move.pbFromPBMove(self,PBMove.new(i.effects[PBEffects::FutureSightMove]))
          pbDisplay(_INTL("{1} took the {2} attack!",i.pbThis,move.name))
          moveuser=@battlers[i.effects[PBEffects::FutureSightUser]]
          if i.isFainted? || move.pbAccuracyCheck(moveuser,i)
            damage=((i.effects[PBEffects::FutureSightDamage]*85)/100).floor
            damage=1 if damage<1
            i.damagestate.reset
            pbCommonAnimation("FutureSight",i,nil)
            move.pbReduceHPDamage(damage,nil,i)
          else
            pbDisplay(_INTL("But it failed!"))
          end
          i.effects[PBEffects::FutureSight]=0
          i.effects[PBEffects::FutureSightMove]=0
          i.effects[PBEffects::FutureSightDamage]=0
          i.effects[PBEffects::FutureSightUser]=-1
          if i.isFainted?
            return if !i.pbFaint
            next
          end
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Rain Dish
      if pbWeather==PBWeather::RAINDANCE && i.hasWorkingAbility(:RAINDISH)
        PBDebug.log("[#{i.pbThis}'s Rain Dish triggered]")
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Rain Dish restored its HP a little!",i.pbThis)) if hpgain>0
      end
      # Dry Skin
      if i.hasWorkingAbility(:DRYSKIN)
        PBDebug.log("[#{i.pbThis}'s Dry Skin triggered]")
        if pbWeather==PBWeather::RAINDANCE
          hpgain=i.pbRecoverHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1}'s Dry Skin was healed by the rain!",i.pbThis)) if hpgain>0
        elsif pbWeather==PBWeather::SUNNYDAY
          @scene.pbDamageAnimation(i,0)
          hploss=i.pbReduceHP((i.totalhp/8).floor)
          pbDisplay(_INTL("{1}'s Dry Skin was hurt by the sunlight!",i.pbThis)) if hploss>0
        end
      end
      # Ice Body
      if pbWeather==PBWeather::HAIL && i.hasWorkingAbility(:ICEBODY)
        PBDebug.log("[#{i.pbThis}'s Ice Body triggered]")
        hpgain=i.pbRecoverHP((i.totalhp/16).floor,true)
        pbDisplay(_INTL("{1}'s Ice Body restored its HP a little!",i.pbThis)) if hpgain>0
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Wish
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Wish]>0
        i.effects[PBEffects::Wish]-=1
        if i.effects[PBEffects::Wish]==0
          PBDebug.log("[#{i.pbThis}'s wish triggered]")
          hpgain=i.pbRecoverHP(i.effects[PBEffects::WishAmount],true)
          if hpgain>0
            wishmaker=pbThisEx(i.index,i.effects[PBEffects::WishMaker])
            pbDisplay(_INTL("{1}'s wish came true!",wishmaker))
          end
        end
      end
    end
    # Fire Pledge + Grass Pledge combination damage - should go here
    for i in priority
      next if i.isFainted?
      # Shed Skin
      if i.hasWorkingAbility(:SHEDSKIN)
        if pbRandom(10)<3 && i.status>0
          case i.status
          when PBStatuses::SLEEP
            pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its sleep]")
          when PBStatuses::POISON
            pbDisplay(_INTL("{1}'s {2} cured its poison problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its poison]")
          when PBStatuses::BURN
            pbDisplay(_INTL("{1}'s {2} cured its burn problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its burn]")
          when PBStatuses::PARALYSIS
            pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its paralysis]")
          when PBStatuses::FROZEN
            pbDisplay(_INTL("{1}'s {2} cured its ice problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its frozen]")
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Hydration
      if i.hasWorkingAbility(:HYDRATION) && pbWeather==PBWeather::RAINDANCE
        if i.status>0
          case i.status
          when PBStatuses::SLEEP
            pbDisplay(_INTL("{1}'s {2} cured its sleep problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its sleep]")
          when PBStatuses::POISON
            pbDisplay(_INTL("{1}'s {2} cured its poison problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its poison]")
          when PBStatuses::BURN
            pbDisplay(_INTL("{1}'s {2} cured its burn problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its burn]")
          when PBStatuses::PARALYSIS
            pbDisplay(_INTL("{1}'s {2} cured its paralysis problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its paralysis]")
          when PBStatuses::FROZEN
            pbDisplay(_INTL("{1}'s {2} cured its ice problem!",i.pbThis,PBAbilities.getName(i.ability)))
            PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured its frozen]")
          end
          i.status=0
          i.statusCount=0
        end
      end
      # Healer
      if i.hasWorkingAbility(:HEALER)
        partner=i.pbPartner
        if partner
          if pbRandom(10)<3 && partner.status>0
            case partner.status
            when PBStatuses::SLEEP
              pbDisplay(_INTL("{1}'s {2} cured its partner's sleep problem!",i.pbThis,PBAbilities.getName(i.ability)))
              PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured #{partner.pbThis(true)}'s sleep]")
            when PBStatuses::POISON
              pbDisplay(_INTL("{1}'s {2} cured its partner's poison problem!",i.pbThis,PBAbilities.getName(i.ability)))
              PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured #{partner.pbThis(true)}'s poison]")
            when PBStatuses::BURN
              pbDisplay(_INTL("{1}'s {2} cured its partner's burn problem!",i.pbThis,PBAbilities.getName(i.ability)))
              PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured #{partner.pbThis(true)}'s burn]")
            when PBStatuses::PARALYSIS
              pbDisplay(_INTL("{1}'s {2} cured its partner's paralysis problem!",i.pbThis,PBAbilities.getName(i.ability)))
              PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured #{partner.pbThis(true)}'s paralysis]")
            when PBStatuses::FROZEN
              pbDisplay(_INTL("{1}'s {2} cured its partner's ice problem!",i.pbThis,PBAbilities.getName(i.ability)))
              PBDebug.log("[#{i.pbThis}'s #{PBAbilities.getName(i.ability)} cured #{partner.pbThis(true)}'s frozen]")
            end
            partner.status=0
            partner.statusCount=0
          end
        end
      end
    end
    # Held berries/Leftovers/Black Sludge
    for i in priority
      next if i.isFainted?
      i.pbBerryCureCheck(true)
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Aqua Ring
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::AquaRing]
        PBDebug.log("[#{i.pbThis}'s Aqua Ring triggered]")
        hpgain=(i.totalhp/16).floor
        hpgain=(hpgain*1.3).floor if i.hasWorkingItem(:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain,true)
        pbDisplay(_INTL("{1}'s Aqua Ring restored its HP a little!",i.pbThis)) if hpgain>0
      end
    end
    # Ingrain
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Ingrain]
        PBDebug.log("[#{i.pbThis}'s Ingrain triggered]")
        hpgain=(i.totalhp/16).floor
        hpgain=(hpgain*1.3).floor if i.hasWorkingItem(:BIGROOT)
        hpgain=i.pbRecoverHP(hpgain,true)
        pbDisplay(_INTL("{1} absorbed nutrients with its roots!",i.pbThis)) if hpgain>0
      end
    end
    # Leech Seed
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::LeechSeed]>=0
        recipient=@battlers[i.effects[PBEffects::LeechSeed]]
        if recipient && !recipient.isFainted? # if recipient exists
          PBDebug.log("[#{i.pbThis}'s Leech Seed triggered]")
          pbCommonAnimation("LeechSeed",recipient,i)
          hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          if i.hasWorkingAbility(:LIQUIDOOZE)
            recipient.pbReduceHP(hploss,true)
            pbDisplay(_INTL("{1} sucked up the liquid ooze!",recipient.pbThis))
          elsif recipient.effects[PBEffects::HealBlock]==0
            hploss=(hploss*1.3).floor if recipient.hasWorkingItem(:BIGROOT)
            recipient.pbRecoverHP(hploss,true)
            pbDisplay(_INTL("{1}'s health was sapped by Leech Seed!",i.pbThis))
          end
          if i.isFainted?
            return if !i.pbFaint
          end
          if recipient.isFainted?
            return if !recipient.pbFaint
          end
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Poison/Bad poison
      if i.status==PBStatuses::POISON
        if i.hasWorkingAbility(:POISONHEAL)
          PBDebug.log("[#{i.pbThis}'s Poison Heal triggered]")
          if i.effects[PBEffects::HealBlock]==0
            if i.hp<i.totalhp
              pbCommonAnimation("Poison",i,nil)
              i.pbRecoverHP((i.totalhp/8).floor,true)
              pbDisplay(_INTL("{1} is healed by poison!",i.pbThis))
            end
            if i.statusCount>0
              i.effects[PBEffects::Toxic]+=1
              i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            end
          end
        else
          PBDebug.log("[#{i.pbThis} took damage from poison/toxic]")
          if i.statusCount==0
            i.pbReduceHP((i.totalhp/8).floor)
          else
            i.effects[PBEffects::Toxic]+=1
            i.effects[PBEffects::Toxic]=[15,i.effects[PBEffects::Toxic]].min
            i.pbReduceHP((i.totalhp/16).floor*i.effects[PBEffects::Toxic])
          end
          i.pbContinueStatus
        end
      end
      # Burn
      if i.status==PBStatuses::BURN
        PBDebug.log("[#{i.pbThis} took damage from burn]")
        if i.hasWorkingAbility(:HEATPROOF)
          PBDebug.log("[#{i.pbThis}'s Heatproof triggered]")
          i.pbReduceHP((i.totalhp/16).floor)
        else
          i.pbReduceHP((i.totalhp/8).floor)
        end
        i.pbContinueStatus
      end
      # Nightmare
      if i.effects[PBEffects::Nightmare]
        if i.status==PBStatuses::SLEEP
          PBDebug.log("[#{i.pbThis} took damage from a nightmare]")
          i.pbReduceHP((i.totalhp/4).floor,true)
          pbDisplay(_INTL("{1} is locked in a nightmare!",i.pbThis))
        else
          i.effects[PBEffects::Nightmare]=false
        end
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Curse
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Curse]
        PBDebug.log("[#{i.pbThis} took damage from a curse]")
        i.pbReduceHP((i.totalhp/4).floor,true)
        pbDisplay(_INTL("{1} is afflicted by the curse!",i.pbThis))
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Multi-turn attacks (Bind/Clamp/Fire Spin/Magma Storm/Sand Tomb/Whirlpool/Wrap)
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::MultiTurn]>0
        i.effects[PBEffects::MultiTurn]-=1
        movename=PBMoves.getName(i.effects[PBEffects::MultiTurnAttack])
        if i.effects[PBEffects::MultiTurn]==0
          PBDebug.log("[Trapping move #{movename} affecting #{i.pbThis} ended]")
          pbDisplay(_INTL("{1} was freed from {2}!",i.pbThis,movename))
        else
          PBDebug.log("[#{i.pbThis} took damage from trapping move #{movename}]")
          if isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:BIND)
            pbCommonAnimation("Bind",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:CLAMP)
            pbCommonAnimation("Clamp",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:FIRESPIN)
            pbCommonAnimation("FireSpin",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:MAGMASTORM)
            pbCommonAnimation("MagmaStorm",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:SANDTOMB)
            pbCommonAnimation("SandTomb",i,nil)
          elsif isConst?(i.effects[PBEffects::MultiTurnAttack],PBMoves,:WRAP)
            pbCommonAnimation("Wrap",i,nil)
          else
            pbCommonAnimation("Wrap",i,nil)
          end
          @scene.pbDamageAnimation(i,0)
          i.pbReduceHP((i.totalhp/16).floor)
          pbDisplay(_INTL("{1} is hurt by {2}!",i.pbThis,movename))
        end
      end  
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Taunt
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Taunt]>0
        i.effects[PBEffects::Taunt]-=1
        if i.effects[PBEffects::Taunt]==0
          pbDisplay(_INTL("{1} recovered from the taunting!",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer taunted]")
        end 
      end
    end
    # Encore
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Encore]>0
        if i.moves[i.effects[PBEffects::EncoreIndex]].id!=i.effects[PBEffects::EncoreMove]
          i.effects[PBEffects::Encore]=0
          i.effects[PBEffects::EncoreIndex]=0
          i.effects[PBEffects::EncoreMove]=0
          PBDebug.log("[#{i.pbThis} is no longer encored (encored move was lost)]")
        else
          i.effects[PBEffects::Encore]-=1
          if i.effects[PBEffects::Encore]==0 || i.moves[i.effects[PBEffects::EncoreIndex]].pp==0
            i.effects[PBEffects::Encore]=0
            pbDisplay(_INTL("{1}'s encore ended!",i.pbThis))
            PBDebug.log("[#{i.pbThis} is no longer encored]")
          end 
        end
      end
    end
    # Disable/Cursed Body
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Disable]>0
        i.effects[PBEffects::Disable]-=1
        if i.effects[PBEffects::Disable]==0
          i.effects[PBEffects::DisableMove]=0
          pbDisplay(_INTL("{1} is disabled no more!",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer disabled]")
        end
      end
    end
    # Magnet Rise
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::MagnetRise]>0
        i.effects[PBEffects::MagnetRise]-=1
        if i.effects[PBEffects::MagnetRise]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer levitating by Magnet Rise]")
        end
      end
    end
    # Telekinesis
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Telekinesis]>0
        i.effects[PBEffects::Telekinesis]-=1
        if i.effects[PBEffects::Telekinesis]==0
          pbDisplay(_INTL("{1} stopped levitating.",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer levitating by Telekinesis]")
        end
      end
    end
    # Heal Block
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::HealBlock]>0
        i.effects[PBEffects::HealBlock]-=1
        if i.effects[PBEffects::HealBlock]==0
          pbDisplay(_INTL("The heal block on {1} ended.",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer Heal Blocked]")
        end
      end
    end
    # Embargo
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Embargo]>0
        i.effects[PBEffects::Embargo]-=1
        if i.effects[PBEffects::Embargo]==0
          pbDisplay(_INTL("The embargo on {1} was lifted.",i.pbThis(true)))
          PBDebug.log("[#{i.pbThis} is no longer affected by an embarge]")
        end
      end
    end
    # Yawn
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Yawn]>0
        i.effects[PBEffects::Yawn]-=1
        if i.effects[PBEffects::Yawn]==0 && i.pbCanSleepYawn?
          PBDebug.log("[#{i.pbThis}'s yawning triggered]")
          i.pbSleep
          pbDisplay(_INTL("{1} fell asleep!",i.pbThis))
        end
      end
    end
    # Perish Song
    perishSongUsers=[]
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::PerishSong]>0
        i.effects[PBEffects::PerishSong]-=1
        pbDisplay(_INTL("{1}'s Perish count fell to {2}!",i.pbThis,i.effects[PBEffects::PerishSong]))
        PBDebug.log("[#{i.pbThis}'s Perish Song count dropped to #{i.effects[PBEffects::PerishSong]}]")
        if i.effects[PBEffects::PerishSong]==0
          perishSongUsers.push(i.effects[PBEffects::PerishSongUser])
          i.pbReduceHP(i.hp,true)
        end
      end
      if i.isFainted?
        return if !i.pbFaint
      end
    end
    if perishSongUsers.length>0
      # If all remaining Pokemon fainted by a Perish Song triggered by a single side
      if (perishSongUsers.find_all{|item| pbIsOpposing?(item) }.length==perishSongUsers.length) ||
         (perishSongUsers.find_all{|item| !pbIsOpposing?(item) }.length==perishSongUsers.length)
        pbJudgeCheckpoint(@battlers[perishSongUsers[0]])
      end
    end
    if @decision>0
      pbGainEXP
      return
    end
    # Reflect
    for i in 0...2
      if sides[i].effects[PBEffects::Reflect]>0
        sides[i].effects[PBEffects::Reflect]-=1
        if sides[i].effects[PBEffects::Reflect]==0
          pbDisplay(_INTL("Your team's Reflect faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Reflect faded!")) if i==1
          PBDebug.log("[Reflect ended on the player's side]") if i==0
          PBDebug.log("[Reflect ended on the opponent's side]") if i==1
        end
      end
    end
    # Light Screen
    for i in 0...2
      if sides[i].effects[PBEffects::LightScreen]>0
        sides[i].effects[PBEffects::LightScreen]-=1
        if sides[i].effects[PBEffects::LightScreen]==0
          pbDisplay(_INTL("Your team's Light Screen faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Light Screen faded!")) if i==1
          PBDebug.log("[Light Screen ended on the player's side]") if i==0
          PBDebug.log("[Light Screen ended on the opponent's side]") if i==1
        end
      end
    end
    # Safeguard
    for i in 0...2
      if sides[i].effects[PBEffects::Safeguard]>0
        sides[i].effects[PBEffects::Safeguard]-=1
        if sides[i].effects[PBEffects::Safeguard]==0
          pbDisplay(_INTL("Your team is no longer protected by Safeguard!")) if i==0
          pbDisplay(_INTL("The opposing team is no longer protected by Safeguard!")) if i==1
          PBDebug.log("[Safeguard ended on the player's side]") if i==0
          PBDebug.log("[Safeguard ended on the opponent's side]") if i==1
        end
      end
    end
    # Mist
    for i in 0...2
      if sides[i].effects[PBEffects::Mist]>0
        sides[i].effects[PBEffects::Mist]-=1
        if sides[i].effects[PBEffects::Mist]==0
          pbDisplay(_INTL("Your team's Mist faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Mist faded!")) if i==1
          PBDebug.log("[Mist ended on the player's side]") if i==0
          PBDebug.log("[Mist ended on the opponent's side]") if i==1
        end
      end
    end
    # Tailwind
    for i in 0...2
      if sides[i].effects[PBEffects::Tailwind]>0
        sides[i].effects[PBEffects::Tailwind]-=1
        if sides[i].effects[PBEffects::Tailwind]==0
          pbDisplay(_INTL("Your team's tailwind stopped blowing!")) if i==0
          pbDisplay(_INTL("The opposing team's tailwind stopped blowing!")) if i==1
          PBDebug.log("[Tailwind ended on the player's side]") if i==0
          PBDebug.log("[Tailwind ended on the opponent's side]") if i==1
        end
      end
    end
    # Lucky Chant
    for i in 0...2
      if sides[i].effects[PBEffects::LuckyChant]>0
        sides[i].effects[PBEffects::LuckyChant]-=1
        if sides[i].effects[PBEffects::LuckyChant]==0
          pbDisplay(_INTL("Your team's Lucky Chant faded!")) if i==0
          pbDisplay(_INTL("The opposing team's Lucky Chant faded!")) if i==1
          PBDebug.log("[Lucky Chant ended on the player's side]") if i==0
          PBDebug.log("[Lucky Chant ended on the opponent's side]") if i==1
        end
      end
    end
    # End of Pledge move combinations - should go here
    # Gravity
    if @field.effects[PBEffects::Gravity]>0
      @field.effects[PBEffects::Gravity]-=1
      if @field.effects[PBEffects::Gravity]==0
        pbDisplay(_INTL("Gravity returned to normal."))
        PBDebug.log("[Strong gravity ended]")
      end
    end
    # Trick Room - should go here
    # Wonder Room - should go here
    # Magic Room
    if @field.effects[PBEffects::MagicRoom]>0
      @field.effects[PBEffects::MagicRoom]-=1
      if @field.effects[PBEffects::MagicRoom]==0
        pbDisplay(_INTL("The area returned to normal."))
        PBDebug.log("[Magic Room ended]")
      end
    end
    # Uproar
    for i in priority
      next if i.isFainted?
      if i.effects[PBEffects::Uproar]>0
        for j in priority
          if !j.isFainted? && j.status==PBStatuses::SLEEP && !j.hasWorkingAbility(:SOUNDPROOF)
            j.effects[PBEffects::Nightmare]=false
            j.status=0
            j.statusCount=0
            pbDisplay(_INTL("{1} woke up in the uproar!",j.pbThis))
            PBDebug.log("[#{j.pbThis} awoke in the uproar]")
          end
        end
        i.effects[PBEffects::Uproar]-=1
        if i.effects[PBEffects::Uproar]==0
          pbDisplay(_INTL("{1} calmed down.",i.pbThis))
          PBDebug.log("[#{i.pbThis} is no longer uproaring]")
        else
          pbDisplay(_INTL("{1} is making an uproar!",i.pbThis)) 
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Speed Boost
      # A Pokémon's turncount is 0 if it became active after the beginning of a round
      if i.turncount>0 && i.hasWorkingAbility(:SPEEDBOOST)
        PBDebug.log("[#{i.pbThis}'s Speed Boost triggered]")
        if !i.pbTooHigh?(PBStats::SPEED)
          i.pbIncreaseStatBasic(PBStats::SPEED,1)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Speed Boost raised its Speed!",i.pbThis))
        end 
      end
      # Bad Dreams
      if i.status==PBStatuses::SLEEP
        if i.pbOpposing1.hasWorkingAbility(:BADDREAMS) ||
           i.pbOpposing2.hasWorkingAbility(:BADDREAMS)
          PBDebug.log("[#{i.pbThis}'s opponent's Bad Dreams triggered]")
          hploss=i.pbReduceHP((i.totalhp/8).floor,true)
          pbDisplay(_INTL("{1} is having a bad dream!",i.pbThis)) if hploss>0
        end
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
      # Harvest - should go here
      # Moody
      if i.hasWorkingAbility(:MOODY)
        PBDebug.log("[#{i.pbThis}'s Moody triggered]")
        randomup=[]; randomdown=[]
        for i in [PBStats::ATTACK,PBStats::DEFENSE,PBStats::SPEED,PBStats::SPATK,
                  PBStats::SPDEF,PBStats::ACCURACY,PBStats::EVASION]
          randomup.push(i) if !i.pbTooHigh?(i)
          randomdown.push(i) if !i.pbTooLow?(i)
        end
        statnames=[_INTL("Attack"),_INTL("Defense"),_INTL("Speed"),_INTL("Special Attack"),
                   _INTL("Special Defense"),_INTL("accuracy"),_INTL("evasiveness")]
        if randomup.length>0
          r=self.pbRandom(randomup.length)
          i.pbIncreaseStatBasic(randomup[r],2)
          pbCommonAnimation("StatUp",i,nil)
          pbDisplay(_INTL("{1}'s Moody sharply raised its {2}!",i.pbThis,statnames[randomup[r]-1]))
        end
        if randomdown.length>0
          r=self.pbRandom(randomdown.length)
          i.pbReduceStatBasic(randomdown[r],1)
          pbCommonAnimation("StatDown",i,nil)
          pbDisplay(_INTL("{1}'s Moody lowered its {2}!",i.pbThis,statnames[randomdown[r]-1]))
        end
      end
    end
    for i in priority
      next if i.isFainted?
      # Toxic Orb
      if i.hasWorkingItem(:TOXICORB) && i.status==0 && i.pbCanPoison?(false)
        PBDebug.log("[#{i.pbThis}'s Toxic Orb triggered]")
        PBDebug.log("[#{i.pbThis}: was poisoned")
        i.status=PBStatuses::POISON
        i.statusCount=1
        i.effects[PBEffects::Toxic]=0
        pbCommonAnimation("Poison",i,nil)
        pbDisplay(_INTL("{1} was poisoned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Flame Orb
      if i.hasWorkingItem(:FLAMEORB) && i.status==0 && i.pbCanBurn?(false)
        PBDebug.log("[#{i.pbThis}'s Flame Orb triggered]")
        PBDebug.log("[#{i.pbThis}: was burned")
        i.status=PBStatuses::BURN
        i.statusCount=0
        pbCommonAnimation("Burn",i,nil)
        pbDisplay(_INTL("{1} was burned by its {2}!",i.pbThis,PBItems.getName(i.item)))
      end
      # Sticky Barb
      if i.hasWorkingItem(:STICKYBARB) && !i.hasWorkingAbility(:MAGICGUARD)
        PBDebug.log("[#{i.pbThis}'s Sticky Barb triggered]")
        pbDisplay(_INTL("{1} is hurt by its {2}!",i.pbThis,PBItems.getName(i.item)))
        @scene.pbDamageAnimation(i,0)
        i.pbReduceHP((i.totalhp/8).floor)
      end
      if i.isFainted?
        return if !i.pbFaint
        next
      end
    end
    # Form checks
    for i in 0...4
      next if @battlers[i].isFainted?
      @battlers[i].pbCheckForm
    end
    pbGainEXP
    pbSwitch
    return if @decision>0
    for i in priority
      next if i.isFainted?
      i.pbAbilitiesOnSwitchIn(false)
    end
    # Healing Wish/Lunar Dance - should go here
    # Spikes/Toxic Spikes/Stealth Rock - should go here (in order of their 1st use)
    for i in 0...4
      if @battlers[i].turncount>0 && @battlers[i].hasWorkingAbility(:TRUANT)
        @battlers[i].effects[PBEffects::Truant]=!@battlers[i].effects[PBEffects::Truant]
      end
      if @battlers[i].effects[PBEffects::LockOn]>0   # Also Mind Reader
        @battlers[i].effects[PBEffects::LockOn]-=1
        @battlers[i].effects[PBEffects::LockOnPos]=-1 if @battlers[i].effects[PBEffects::LockOn]==0
      end
      @battlers[i].effects[PBEffects::Flinch]=false
      @battlers[i].effects[PBEffects::FollowMe]=false
      @battlers[i].effects[PBEffects::HelpingHand]=false
      @battlers[i].effects[PBEffects::MagicCoat]=false
      @battlers[i].effects[PBEffects::Snatch]=false
      @battlers[i].effects[PBEffects::Charge]-=1 if @battlers[i].effects[PBEffects::Charge]>0
      @battlers[i].lastHPLost=0
      @battlers[i].lastAttacker=-1
      @battlers[i].effects[PBEffects::Counter]=-1
      @battlers[i].effects[PBEffects::CounterTarget]=-1
      @battlers[i].effects[PBEffects::MirrorCoat]=-1
      @battlers[i].effects[PBEffects::MirrorCoatTarget]=-1
    end
    # invalidate stored priority
    @usepriority=false
  end

################################################################################
# End of battle.
################################################################################
  def pbEndOfBattle(canlose=false)
    case @decision
    ##### WIN #####
    when 1
      PBDebug.log("***Player won***")
      if @opponent
        @scene.pbTrainerBattleSuccess
        if @opponent.is_a?(Array)
          pbDisplayPaused(_INTL("{1} defeated {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
        else
          pbDisplayPaused(_INTL("{1} defeated\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
        end
        @scene.pbShowOpponent(0)
        pbDisplayPaused(@endspeech.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        if @opponent.is_a?(Array)
          @scene.pbHideOpponent
          @scene.pbShowOpponent(1)
          pbDisplayPaused(@endspeech2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        end
        # Calculate money gained for winning
        if @internalbattle
          tmoney=0
          if @opponent.is_a?(Array)   # Double battles
            maxlevel1=0; maxlevel2=0; limit=pbSecondPartyBegin(1)
            for i in 0...limit
              if @party2[i]
                maxlevel1=@party2[i].level if maxlevel1<@party2[i].level
              end
              if @party2[i+limit]
                maxlevel2=@party2[i+limit].level if maxlevel1<@party2[i+limit].level
              end
            end
            tmoney+=maxlevel1*@opponent[0].moneyEarned
            tmoney+=maxlevel2*@opponent[1].moneyEarned
          else
            maxlevel=0
            for i in @party2
              next if !i
              maxlevel=i.level if maxlevel<i.level
            end
            tmoney+=maxlevel*@opponent.moneyEarned
          end
          # If Amulet Coin/Luck Incense's effect applies, double money earned
          tmoney*=2 if @amuletcoin
          oldmoney=self.pbPlayer.money
          self.pbPlayer.money+=tmoney
          moneygained=self.pbPlayer.money-oldmoney
          if moneygained>0
            pbDisplayPaused(_INTL("{1} got ${2}\r\nfor winning!",self.pbPlayer.name,tmoney))
          end
        end
      end
      if @internalbattle && @extramoney>0
        @extramoney*=2 if @amuletcoin
        oldmoney=self.pbPlayer.money
        self.pbPlayer.money+=@extramoney
        moneygained=self.pbPlayer.money-oldmoney
        if moneygained>0
          pbDisplayPaused(_INTL("{1} picked up ${2}!",self.pbPlayer.name,@extramoney))
        end
      end
      for pkmn in @snaggedpokemon
        pbStorePokemon(pkmn)
        self.pbPlayer.shadowcaught=[] if !self.pbPlayer.shadowcaught
        self.pbPlayer.shadowcaught[pkmn.species]=true
      end
      @snaggedpokemon.clear
    ##### LOSE, DRAW #####
    when 2, 5
      PBDebug.log("***Player lost***") if @decision==2
      PBDebug.log("***Player drew with opponent***") if @decision==5
      if @internalbattle
        pbDisplayPaused(_INTL("{1} is out of usable Pokémon!",self.pbPlayer.name))
        moneylost=pbMaxLevelFromIndex(0)   # Player's Pokémon only, not partner's
        multiplier=[8,16,24,36,48,60,80,100,120]
        moneylost*=multiplier[[multiplier.length-1,self.pbPlayer.numbadges].min]
        moneylost=self.pbPlayer.money if moneylost>self.pbPlayer.money
        moneylost=0 if $game_switches[NO_MONEY_LOSS]
        oldmoney=self.pbPlayer.money
        self.pbPlayer.money-=moneylost
        lostmoney=oldmoney-self.pbPlayer.money
        if @opponent
          if @opponent.is_a?(Array)
            pbDisplayPaused(_INTL("{1} lost against {2} and {3}!",self.pbPlayer.name,@opponent[0].fullname,@opponent[1].fullname))
          else
            pbDisplayPaused(_INTL("{1} lost against\r\n{2}!",self.pbPlayer.name,@opponent.fullname))
          end
          if moneylost>0
            pbDisplayPaused(_INTL("{1} paid ${2}\r\nas the prize money...",self.pbPlayer.name,lostmoney))  
            pbDisplayPaused(_INTL("...")) if !canlose
          end
        else
          if moneylost>0
            pbDisplayPaused(_INTL("{1} panicked and lost\r\n${2}...",self.pbPlayer.name,lostmoney))
            pbDisplayPaused(_INTL("...")) if !canlose
          end
        end
        pbDisplayPaused(_INTL("{1} blacked out!",self.pbPlayer.name)) if !canlose
      elsif @decision==2
        @scene.pbShowOpponent(0)
        pbDisplayPaused(@endspeechwin.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        if @opponent.is_a?(Array)
          @scene.pbHideOpponent
          @scene.pbShowOpponent(1)
          pbDisplayPaused(@endspeechwin2.gsub(/\\[Pp][Nn]/,self.pbPlayer.name))
        end
      end
    end
    # Pass on Pokérus within the party
    infected=[]
    for i in 0...$Trainer.party.length
      if $Trainer.party[i].pokerusStage==1
        infected.push(i)
      end
    end
    if infected.length>=1
      for i in infected
        strain=$Trainer.party[i].pokerus/16
        if i>0 && $Trainer.party[i-1].pokerusStage==0
          $Trainer.party[i-1].givePokerus(strain) if rand(3)==0
        end
        if i<$Trainer.party.length-1 && $Trainer.party[i+1].pokerusStage==0
          $Trainer.party[i+1].givePokerus(strain) if rand(3)==0
        end
      end
    end
    @scene.pbEndBattle(@decision)
    for i in @battlers
      i.pbResetForm
    end
    for i in $Trainer.party
      i.setItem(i.itemInitial)
      i.itemInitial=i.itemRecycle=0
    end
    return @decision
  end
end