ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8

def pbIsHiddenMove?(move)
  return false if !$ItemData
  for i in 0...$ItemData.length
    next if !pbIsHiddenMachine?(i)
    atk=$ItemData[i][ITEMMACHINE]
    return true if move==atk
  end
  return false
end

def pbGetPrice(item)
  return $ItemData[item][ITEMPRICE]
end

def pbGetPocket(item)
  return $ItemData[item][ITEMPOCKET]
end

# Important items can't be sold, given to hold, or tossed.
def pbIsImportantItem?(item)
  return $ItemData[item] && (pbIsKeyItem?(item) || pbIsHiddenMachine?(item) ||
                             (INFINITETMS && pbIsTechnicalMachine?(item))
                            )
end

def pbIsMachine?(item)
  return $ItemData[item] && (pbIsTechnicalMachine?(item) || pbIsHiddenMachine?(item))
end

def pbIsTechnicalMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==3)
end

def pbIsHiddenMachine?(item)
  return $ItemData[item] && ($ItemData[item][ITEMUSE]==4)
end

def pbIsMail?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==1 || $ItemData[item][ITEMTYPE]==2)
end

def pbIsSnagBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 ||
                            ($ItemData[item][ITEMTYPE]==4 && $PokemonGlobal.snagMachine))
end

def pbIsPokeBall?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==3 || $ItemData[item][ITEMTYPE]==4)
end

def pbIsBerry?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==5)
end

def pbIsKeyItem?(item)
  return $ItemData[item] && ($ItemData[item][ITEMTYPE]==6)
end

def pbIsBattleEndingItem?(item)
  return false
end

def pbIsEvolutionStone?(item)
  return true if isConst?(item,PBItems,:FIRESTONE) ||
                 isConst?(item,PBItems,:THUNDERSTONE) ||
                 isConst?(item,PBItems,:WATERSTONE) ||
                 isConst?(item,PBItems,:LEAFSTONE) ||
                 isConst?(item,PBItems,:MOONSTONE) ||
                 isConst?(item,PBItems,:SUNSTONE) ||
                 isConst?(item,PBItems,:DUSKSTONE) ||
                 isConst?(item,PBItems,:DAWNSTONE) ||
                 isConst?(item,PBItems,:SHINYSTONE)
  return false
end

def pbIsMulch?(item)
  return true if isConst?(item,PBItems,:GROWTHMULCH) ||
                 isConst?(item,PBItems,:DAMPMULCH) ||
                 isConst?(item,PBItems,:STABLEMULCH) ||
                 isConst?(item,PBItems,:GOOEYMULCH)
  return false
end

def pbTopRightWindow(text)
  window=Window_AdvancedTextPokemon.new(text)
  window.z=99999
  window.width=198
  window.y=0
  window.x=Graphics.width-window.width
  pbPlayDecisionSE()
  loop do
    Graphics.update
    Input.update
    window.update
    if Input.trigger?(Input::C)
      break
    end
  end
  window.dispose
end



class ItemHandlerHash < HandlerHash
  def initialize
    super(:PBItems)
  end
end



module ItemHandlers
  UseFromBag=ItemHandlerHash.new
  UseInField=ItemHandlerHash.new
  UseOnPokemon=ItemHandlerHash.new
  BattleUseOnBattler=ItemHandlerHash.new
  BattleUseOnPokemon=ItemHandlerHash.new
  UseInBattle=ItemHandlerHash.new

  def self.addUseFromBag(item,proc)
    UseFromBag.add(item,proc)
  end

  def self.addUseInField(item,proc)
    UseInField.add(item,proc)
  end

  def self.addUseOnPokemon(item,proc)
    UseOnPokemon.add(item,proc)
  end

  def self.addBattleUseOnBattler(item,proc)
    BattleUseOnBattler.add(item,proc)
  end

  def self.addBattleUseOnPokemon(item,proc)
    BattleUseOnPokemon.add(item,proc)
  end

  def self.hasOutHandler(item)                       # Shows "Use" option in Bag
    return UseFromBag[item]!=nil || UseOnPokemon[item]!=nil
  end

  def self.hasKeyItemHandler(item)              # Shows "Register" option in Bag
    return UseInField[item]!=nil
  end

  def self.hasBattleUseOnBattler(item)
    return BattleUseOnBattler[item]!=nil
  end

  def self.hasBattleUseOnPokemon(item)
    return BattleUseOnPokemon[item]!=nil
  end

  def self.hasUseInBattle(item)
    return UseInBattle[item]!=nil
  end

  def self.triggerUseFromBag(item)
    # Return value:
    # 0 - Item not used
    # 1 - Item used, don't end screen
    # 2 - Item used, end screen
    # 3 - Item used, consume item
    # 4 - Item used, end screen, consume item
    if !UseFromBag[item]
      # Check the UseInField handler if present
      if UseInField[item]
        UseInField.trigger(item)
        return 1 # item was used
      end
      return 0 # item was not used
    else
      UseFromBag.trigger(item)
    end
  end

  def self.triggerUseInField(item)
    # No return value
    if !UseInField[item]
      return false
    else
      UseInField.trigger(item)
      return true
    end
  end

  def self.triggerUseOnPokemon(item,pokemon,scene)
    # Returns whether item was used
    if !UseOnPokemon[item]
      return false
    else
      return UseOnPokemon.trigger(item,pokemon,scene)
    end
  end

  def self.triggerBattleUseOnBattler(item,battler,scene)
    # Returns whether item was used
    if !BattleUseOnBattler[item]
      return false
    else
      return BattleUseOnBattler.trigger(item,battler,scene)
    end
  end

  def self.triggerBattleUseOnPokemon(item,pokemon,battler,scene)
    # Returns whether item was used
    if !BattleUseOnPokemon[item]
      return false
    else
      return BattleUseOnPokemon.trigger(item,pokemon,battler,scene)
    end
  end

  def self.triggerUseInBattle(item,battler,battle)
    # Returns whether item was used
    if !UseInBattle[item]
      return
    else
      UseInBattle.trigger(item,battler,battle)
    end
  end
end



def pbChangeLevel(pokemon,newlevel,scene)
  newlevel=1 if newlevel<1
  newlevel=PBExperience::MAXLEVEL if newlevel>PBExperience::MAXLEVEL
  if pokemon.level>newlevel
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    pokemon.level=newlevel
    pokemon.calcStats
    scene.pbRefresh
    Kernel.pbMessage(_INTL("{1} was downgraded to Level {2}!",pokemon.name,pokemon.level))
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
  elsif pokemon.level==newlevel
    Kernel.pbMessage(_INTL("{1}'s level remained unchanged.",pokemon.name))
  else
    attackdiff=pokemon.attack
    defensediff=pokemon.defense
    speeddiff=pokemon.speed
    spatkdiff=pokemon.spatk
    spdefdiff=pokemon.spdef
    totalhpdiff=pokemon.totalhp
    oldlevel=pokemon.level
    pokemon.level=newlevel
    pokemon.changeHappiness("level up")
    pokemon.calcStats
    scene.pbRefresh
    Kernel.pbMessage(_INTL("{1} was elevated to Level {2}!",pokemon.name,pokemon.level))
    attackdiff=pokemon.attack-attackdiff
    defensediff=pokemon.defense-defensediff
    speeddiff=pokemon.speed-speeddiff
    spatkdiff=pokemon.spatk-spatkdiff
    spdefdiff=pokemon.spdef-spdefdiff
    totalhpdiff=pokemon.totalhp-totalhpdiff
    pbTopRightWindow(_INTL("Max. HP<r>+{1}\r\nAttack<r>+{2}\r\nDefense<r>+{3}\r\nSp. Atk<r>+{4}\r\nSp. Def<r>+{5}\r\nSpeed<r>+{6}",
       totalhpdiff,attackdiff,defensediff,spatkdiff,spdefdiff,speeddiff))
    pbTopRightWindow(_INTL("Max. HP<r>{1}\r\nAttack<r>{2}\r\nDefense<r>{3}\r\nSp. Atk<r>{4}\r\nSp. Def<r>{5}\r\nSpeed<r>{6}",
       pokemon.totalhp,pokemon.attack,pokemon.defense,pokemon.spatk,pokemon.spdef,pokemon.speed))
    movelist=pokemon.getMoveList
    for i in movelist
      if i[0]==pokemon.level          # Learned a new move
        pbLearnMove(pokemon,i[1],true)
      end
    end
    newspecies=pbCheckEvolution(pokemon)
    if newspecies>0
      pbFadeOutInWithMusic(99999){
         evo=PokemonEvolutionScene.new
         evo.pbStartScreen(pokemon,newspecies)
         evo.pbEvolution
         evo.pbEndScreen
      }
    end
  end
end

def pbItemRestoreHP(pokemon,restorehp)
  newhp=pokemon.hp+restorehp
  newhp=pokemon.totalhp if newhp>pokemon.totalhp
  hpgain=newhp-pokemon.hp
  pokemon.hp=newhp
  return hpgain
end

def pbHPItem(pokemon,restorehp,scene)
  if pokemon.hp<=0 || pokemon.hp==pokemon.totalhp || pokemon.isEgg?
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  else
    hpgain=pbItemRestoreHP(pokemon,restorehp)
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored by {2} points.",pokemon.name,hpgain))
    return true
  end
end

def pbBattleHPItem(pokemon,battler,restorehp,scene)
  if pokemon.hp<=0 || pokemon.hp==pokemon.totalhp || pokemon.isEgg?
    scene.pbDisplay(_INTL("But it had no effect!"))
    return false
  else
    hpgain=pbItemRestoreHP(pokemon,restorehp)
    battler.hp=pokemon.hp if battler
    scene.pbRefresh
    scene.pbDisplay(_INTL("{1}'s HP was restored.",pokemon.name,hpgain))
    return true
  end
end

def pbJustRaiseEffortValues(pokemon,ev,evgain)
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510
    # Bug Fix: must use "-=" instead of "="
    evgain-=totalev+evgain-510
  end
  if pokemon.ev[ev]+evgain>255
    # Bug Fix: must use "-=" instead of "="
    evgain-=pokemon.ev[ev]+evgain-255
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRaiseEffortValues(pokemon,ev,evgain=10,evlimit=true)
  if pokemon.ev[ev]>=100 && evlimit
    return 0
  end
  totalev=0
  for i in 0...6
    totalev+=pokemon.ev[i]
  end
  if totalev+evgain>510
    evgain=510-totalev
  end
  if pokemon.ev[ev]+evgain>255
    evgain=255-pokemon.ev[ev]
  end
  if evlimit && pokemon.ev[ev]+evgain>100
    evgain=100-pokemon.ev[ev]
  end
  if evgain>0
    pokemon.ev[ev]+=evgain
    pokemon.calcStats
  end
  return evgain
end

def pbRaiseHappinessAndLowerEV(pokemon,scene,ev,messages)
  if pokemon.happiness==255 && pokemon.ev[ev]==0
    scene.pbDisplay(_INTL("It won't have any effect."))
    return false
  elsif pokemon.happiness==255
    pokemon.ev[ev]-=10
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[0])
    return true
  elsif pokemon.ev[ev]==0
    pokemon.changeHappiness("EV berry")
    scene.pbRefresh
    scene.pbDisplay(messages[1])
    return true
  else
    pokemon.changeHappiness("EV berry")
    pokemon.ev[ev]-=10
    pokemon.ev[ev]=0 if pokemon.ev[ev]<0
    pokemon.calcStats
    scene.pbRefresh
    scene.pbDisplay(messages[2])
    return true
  end
end

def pbRestorePP(pokemon,move,pp)
  return 0 if pokemon.moves[move].id==0
  return 0 if pokemon.moves[move].totalpp==0
  newpp=pokemon.moves[move].pp+pp
  if newpp>pokemon.moves[move].totalpp
    newpp=pokemon.moves[move].totalpp
  end
  oldpp=pokemon.moves[move].pp
  pokemon.moves[move].pp=newpp
  return newpp-oldpp
end

def pbBattleRestorePP(pokemon,battler,move,pp)
  ret=pbRestorePP(pokemon,move,pp)
  if ret>0
    battler.pbSetPP(battler.moves[move],pokemon.moves[move].pp) if battler
  end
  return ret
end

def pbBikeCheck
  if $PokemonGlobal.surfing ||
     (!$PokemonGlobal.bicycle && pbGetTerrainTag==PBTerrain::TallGrass)
    Kernel.pbMessage(_INTL("Can't use that here."))
    return false
  end
  if $game_player.pbHasDependentEvents?
    Kernel.pbMessage(_INTL("It can't be used when you have someone with you."))
    return false
  end
  if $PokemonGlobal.bicycle
    if pbGetMetadata($game_map.map_id,MetadataBicycleAlways)
      Kernel.pbMessage(_INTL("You can't dismount your Bike here."))
      return false
    end
    return true
  else
    val=pbGetMetadata($game_map.map_id,MetadataBicycle)
    val=pbGetMetadata($game_map.map_id,MetadataOutdoor) if val==nil
    if !val
      Kernel.pbMessage(_INTL("Can't use that here."))
      return false
    end
    return true
  end
end

def pbClosestHiddenItem
  result = []
  playerX=$game_player.x
  playerY=$game_player.y
  for event in $game_map.events.values
    next if event.name!="HiddenItem"
    next if (playerX-event.x).abs>=8
    next if (playerY-event.y).abs>=6
    next if $game_self_switches[[$game_map.map_id,event.id,"A"]]
    result.push(event)
  end
  return nil if result.length==0
  ret=nil
  retmin=0
  for event in result
    dist=(playerX-event.x).abs+(playerY-event.y).abs
    if !ret || retmin>dist
      ret=event
      retmin=dist
    end
  end
  return ret
end

def Kernel.pbUseKeyItemInField(item)
  if !ItemHandlers.triggerUseInField(item)
    Kernel.pbMessage(_INTL("Can't use that here."))
  end
end

def pbSpeciesCompatible?(species,move)
  ret=false
  return false if species<=0
  data=load_data("Data/tm.dat")
  return false if !data[move]
  return data[move].any? {|item| item==species }
end

def pbForgetMove(pokemon,moveToLearn)
  ret=-1
  pbFadeOutIn(99999){
     scene=PokemonSummaryScene.new
     screen=PokemonSummary.new(scene)
     ret=screen.pbStartForgetScreen([pokemon],0,moveToLearn)
  }
  return ret
end

def pbLearnMove(pokemon,move,ignoreifknown=false,bymachine=false)
  return false if !pokemon
  movename=PBMoves.getName(move)
  if pokemon.isEgg? && !$DEBUG
    Kernel.pbMessage(_INTL("{1} can't be taught to an Egg.",movename))
    return false
  end
  if pokemon.respond_to?("isShadow?") && pokemon.isShadow?
    Kernel.pbMessage(_INTL("{1} can't be taught to this Pokémon.",movename))
    return false
  end
  pkmnname=pokemon.name
  for i in 0...4
    if pokemon.moves[i].id==move
      Kernel.pbMessage(_INTL("{1} already knows\r\n{2}.",pkmnname,movename)) if !ignoreifknown
      return false
    end
    if pokemon.moves[i].id==0
      pokemon.moves[i]=PBMove.new(move)
      Kernel.pbMessage(_INTL("{1} learned {2}!\\se[itemlevel]",pkmnname,movename))
      return true
    end
  end
  loop do
    Kernel.pbMessage(_INTL("{1} is trying to\r\nlearn {2}.\1",pkmnname,movename))
    Kernel.pbMessage(_INTL("But {1} can't learn more than four moves.\1",pkmnname))
    if Kernel.pbConfirmMessage(_INTL("Delete a move to make\r\nroom for {1}?",movename))
      Kernel.pbMessage(_INTL("Which move should be forgotten?"))
      forgetmove=pbForgetMove(pokemon,move)
      if forgetmove>=0
        oldmovename=PBMoves.getName(pokemon.moves[forgetmove].id)
        oldmovepp=pokemon.moves[forgetmove].pp
        pokemon.moves[forgetmove]=PBMove.new(move) # Replaces current/total PP
        pokemon.moves[forgetmove].pp=[oldmovepp,pokemon.moves[forgetmove].totalpp].min if bymachine
        Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
        Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pkmnname,oldmovename))
        Kernel.pbMessage(_INTL("And...\1"))
        Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[itemlevel]",pkmnname,movename))
        return true
      elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
        Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
        return false
      end
    elsif Kernel.pbConfirmMessage(_INTL("Should {1} stop learning {2}?",pkmnname,movename))
      Kernel.pbMessage(_INTL("{1} did not learn {2}.",pkmnname,movename))
      return false
    end
  end
end

def pbCheckUseOnPokemon(item,pokemon,screen)
  return pokemon && !pokemon.isEgg?
end

def pbConsumeItemInBattle(bag,item)
  if item!=0 && $ItemData[item][ITEMBATTLEUSE]!=3 &&
                $ItemData[item][ITEMBATTLEUSE]!=4 &&
                $ItemData[item][ITEMBATTLEUSE]!=0
    # Delete the item just used from stock
    $PokemonBag.pbDeleteItem(item)
  end
end

def pbUseItem(bag,item,bagscene=nil)
  found=false
  if $ItemData[item][ITEMUSE]==3 || $ItemData[item][ITEMUSE]==4    # TM or HM
    machine=$ItemData[item][ITEMMACHINE]
    ret=true
    return 0 if machine==nil
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    movename=PBMoves.getName(machine)
    if pbIsHiddenMachine?(item)
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up an HM."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    else
      Kernel.pbMessage(_INTL("\\se[accesspc]Booted up a TM."))
      Kernel.pbMessage(_INTL("It contained {1}.\1",movename))
    end
    if !Kernel.pbConfirmMessage(_INTL("Teach {1} to a Pokémon?",movename))
      return 0
    elsif pbMoveTutorChoose(machine,nil,true)
      bag.pbDeleteItem(item) if pbIsTechnicalMachine?(item) && !INFINITETMS
      return 1
    else
      return 0
    end
  elsif $ItemData[item][ITEMUSE]==1 || $ItemData[item][ITEMUSE]==5 # Item is usable on a Pokémon
    if $Trainer.pokemonCount==0
      Kernel.pbMessage(_INTL("There is no Pokémon."))
      return 0
    end
    ret=false
    annot=nil
    if pbIsEvolutionStone?(item)
      annot=[]
      for pkmn in $Trainer.party
        elig=(pbCheckEvolution(pkmn,item)>0)
        annot.push(elig ? _INTL("ABLE") : _INTL("NOT ABLE"))
      end
    end
    pbFadeOutIn(99999){
       scene=PokemonScreen_Scene.new
       screen=PokemonScreen.new(scene,$Trainer.party)
       screen.pbStartScene(_INTL("Use on which Pokémon?"),false,annot)
       loop do
         scene.pbSetHelpText(_INTL("Use on which Pokémon?"))
         chosen=screen.pbChoosePokemon
         if chosen>=0
           pokemon=$Trainer.party[chosen]
           if !pbCheckUseOnPokemon(item,pokemon,screen)
             pbPlayBuzzerSE()
           else
             ret=ItemHandlers.triggerUseOnPokemon(item,pokemon,screen)
             if ret && $ItemData[item][ITEMUSE]==1 # Usable on Pokémon, consumed
               bag.pbDeleteItem(item)
             end
             if bag.pbQuantity(item)<=0
               Kernel.pbMessage(_INTL("You used your last {1}.",
                  PBItems.getName(item))) if bag.pbQuantity(item)<=0
               break
             end
           end
         else
           ret=false
           break
         end
       end
       screen.pbEndScene
       bagscene.pbRefresh if bagscene
    }
    return ret ? 1 : 0
  elsif $ItemData[item][ITEMUSE]==2 # Item is usable from bag
    intret=ItemHandlers.triggerUseFromBag(item)
    case intret
    when 0
      return 0
    when 1 # Item used
      return 1
    when 2 # Item used, end screen
      return 2
    when 3 # Item used, consume item
      bag.pbDeleteItem(item)
      return 1
    when 4 # Item used, end screen and consume item
      bag.pbDeleteItem(item)
      return 2
    else
      Kernel.pbMessage(_INTL("Can't use that here."))
      return 0
    end
  else
    Kernel.pbMessage(_INTL("Can't use that here."))
    return 0
  end
end

def Kernel.pbChooseItem(var=0)
  ret=0
  scene=PokemonBag_Scene.new
  screen=PokemonBagScreen.new(scene,$PokemonBag)
  pbFadeOutIn(99999) { 
    ret=screen.pbChooseItemScreen
  }
  $game_variables[var]=ret if var>0
  return ret
end

# Shows a list of items to choose from, with the chosen item's ID being stored
# in the given Global Variable. Only items which the player has are listed.
def pbChooseItemFromList(message,variable,*args)
  commands=[]
  itemid=[]
  for item in args
    if hasConst?(PBItems,item)
      id=getConst(PBItems,item)
      if $PokemonBag.pbQuantity(id)>0
        commands.push(PBItems.getName(id))
        itemid.push(id)
      end
    end
  end
  if commands.length==0
    $game_variables[variable]=0
    return 0
  end
  commands.push(_INTL("Cancel"))
  itemid.push(0)
  ret=Kernel.pbMessage(message,commands,-1)
  if ret<0 || ret>=commands.length-1
    $game_variables[variable]=-1
    return -1
  else
    $game_variables[variable]=itemid[ret]
    return itemid[ret]
  end
end