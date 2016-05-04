class PokeBattle_Pokemon
  def form
    v=MultipleForms.call("getForm",self)
    if v!=nil
      self.form=v if !@form || v!=@form
      return v
    end
    return @form || 0
  end

  def form=(value)
    @form=value
    self.calcStats
    MultipleForms.call("onSetForm",self,value)
  end

  def formNoCall=(value)
    @form=value
    self.calcStats
  end

  def hasMegaForm?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil
  end

  def isMega?
    v=MultipleForms.call("getMegaForm",self)
    return v!=nil && v==@form
  end

  def makeMega
    v=MultipleForms.call("getMegaForm",self)
    self.form=v if v!=nil
  end

  def makeUnmega
    v=MultipleForms.call("getUnmegaForm",self)
    self.form=v if v!=nil
  end

  def megaName
    v=MultipleForms.call("getMegaName",self)
    return v if v!=nil
    return ""
  end

  alias __mf_baseStats baseStats
  alias __mf_ability ability
  alias __mf_type1 type1
  alias __mf_type2 type2
  alias __mf_weight weight
  alias __mf_getMoveList getMoveList
  alias __mf_wildHoldItems wildHoldItems
  alias __mf_baseExp baseExp
  alias __mf_evYield evYield
  alias __mf_initialize initialize

  def baseStats
    v=MultipleForms.call("getBaseStats",self)
    return v if v!=nil
    return self.__mf_baseStats
  end

  def ability
    v=MultipleForms.call("ability",self)
    return v if v!=nil
    return self.__mf_ability
  end

  def type1
    v=MultipleForms.call("type1",self)
    return v if v!=nil
    return self.__mf_type1
  end

  def type2
    v=MultipleForms.call("type2",self)
    return v if v!=nil
    return self.__mf_type2
  end

  def weight
    v=MultipleForms.call("weight",self)
    return v if v!=nil
    return self.__mf_weight
  end

  def getMoveList
    v=MultipleForms.call("getMoveList",self)
    return v if v!=nil
    return self.__mf_getMoveList
  end

  def wildHoldItems
    v=MultipleForms.call("wildHoldItems",self)
    return v if v!=nil
    return self.__mf_wildHoldItems
  end

  def baseExp
    v=MultipleForms.call("baseExp",self)
    return v if v!=nil
    return self.__mf_baseExp
  end

  def evYield
    v=MultipleForms.call("evYield",self)
    return v if v!=nil
    return self.__mf_evYield
  end

  def initialize(*args)
    __mf_initialize(*args)
    f=MultipleForms.call("getFormOnCreation",self)
    if f
      self.form=f
      self.resetMoves
    end
  end
end



class PokeBattle_RealBattlePeer
  def pbOnEnteringBattle(battle,pokemon)
    f=MultipleForms.call("getFormOnEnteringBattle",pokemon)
    if f
      pokemon.form=f
    end
  end
end



module MultipleForms
  @@formSpecies=HandlerHash.new(:PBSpecies)

  def self.copy(sym,*syms)
    @@formSpecies.copy(sym,*syms)
  end

  def self.register(sym,hash)
    @@formSpecies.add(sym,hash)
  end

  def self.registerIf(cond,hash)
    @@formSpecies.addIf(cond,hash)
  end

  def self.hasFunction?(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return sp && sp[func]
  end

  def self.getFunction(pokemon,func)
    spec=(pokemon.is_a?(Numeric)) ? pokemon : pokemon.species
    sp=@@formSpecies[spec]
    return (sp && sp[func]) ? sp[func] : nil
  end

  def self.call(func,pokemon,*args)
    sp=@@formSpecies[pokemon.species]
    return nil if !sp || !sp[func]
    return sp[func].call(pokemon,*args)
  end
end



def drawSpot(bitmap,spotpattern,x,y,red,green,blue)
  height=spotpattern.length
  width=spotpattern[0].length
  for yy in 0...height
    spot=spotpattern[yy]
    for xx in 0...width
      if spot[xx]==1
        xOrg=(x+xx)<<1
        yOrg=(y+yy)<<1
        color=bitmap.get_pixel(xOrg,yOrg)
        r=color.red+red
        g=color.green+green
        b=color.blue+blue
        color.red=[[r,0].max,255].min
        color.green=[[g,0].max,255].min
        color.blue=[[b,0].max,255].min
        bitmap.set_pixel(xOrg,yOrg,color)
        bitmap.set_pixel(xOrg+1,yOrg,color)
        bitmap.set_pixel(xOrg,yOrg+1,color)
        bitmap.set_pixel(xOrg+1,yOrg+1,color)
      end   
    end
  end
end

def pbSpindaSpots(pokemon,bitmap)
  spot1=[
     [0,0,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,0,0]
  ]
  spot2=[
     [0,0,1,1,1,0,0],
     [0,1,1,1,1,1,0],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1],
     [0,1,1,1,1,1,0],
     [0,0,1,1,1,0,0]
  ]
  spot3=[
     [0,0,0,0,0,1,1,1,1,0,0,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1,1],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,1,1,1,1,1,1,1,0,0,0],
     [0,0,0,0,0,1,1,1,0,0,0,0,0]
  ]
  spot4=[
     [0,0,0,0,1,1,1,0,0,0,0,0],
     [0,0,1,1,1,1,1,1,1,0,0,0],
     [0,1,1,1,1,1,1,1,1,1,0,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,1],
     [1,1,1,1,1,1,1,1,1,1,1,0],
     [0,1,1,1,1,1,1,1,1,1,1,0],
     [0,0,1,1,1,1,1,1,1,1,0,0],
     [0,0,0,0,1,1,1,1,1,0,0,0]
  ]
  id=pokemon.personalID
  h=(id>>28)&15
  g=(id>>24)&15
  f=(id>>20)&15
  e=(id>>16)&15
  d=(id>>12)&15
  c=(id>>8)&15
  b=(id>>4)&15
  a=(id)&15
  if pokemon.isShiny?
    drawSpot(bitmap,spot1,b+33,a+25,-75,-10,-150)
    drawSpot(bitmap,spot2,d+21,c+24,-75,-10,-150)
    drawSpot(bitmap,spot3,f+39,e+7,-75,-10,-150)
    drawSpot(bitmap,spot4,h+15,g+6,-75,-10,-150)
  else
    drawSpot(bitmap,spot1,b+33,a+25,0,-115,-75)
    drawSpot(bitmap,spot2,d+21,c+24,0,-115,-75)
    drawSpot(bitmap,spot3,f+39,e+7,0,-115,-75)
    drawSpot(bitmap,spot4,h+15,g+6,0,-115,-75)
  end
end

MultipleForms.register(:UNOWN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(28)
}
})

MultipleForms.register(:SPINDA,{
"alterBitmap"=>proc{|pokemon,bitmap|
   pbSpindaSpots(pokemon,bitmap)
}
})

MultipleForms.register(:CASTFORM,{
"type1"=>proc{|pokemon|
   next if pokemon.form==0            # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Sunny Form
   when 2; next getID(PBTypes,:WATER) # Rainy Form
   when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0            # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)  # Sunny Form
   when 2; next getID(PBTypes,:WATER) # Rainy Form
   when 3; next getID(PBTypes,:ICE)   # Snowy Form
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEOXYS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0               # Normal Forme
   case pokemon.form
   when 1; next [50,180, 20,150,180, 20] # Attack Forme
   when 2; next [50, 70,160, 90, 70,160] # Defense Forme
   when 3; next [50, 95, 90,180, 95, 90] # Speed Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0    # Normal Forme
   case pokemon.form
   when 1; next [0,2,0,0,1,0] # Attack Forme
   when 2; next [0,0,2,0,0,1] # Defense Forme
   when 3; next [0,0,0,3,0,0] # Speed Forme
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                     [25,:TAUNT],[33,:PURSUIT],[41,:PSYCHIC],[49,:SUPERPOWER],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:COSMICPOWER],
                     [81,:ZAPCANNON],[89,:PSYCHOBOOST],[97,:HYPERBEAM]]
   when 2; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:TELEPORT],
                     [25,:KNOCKOFF],[33,:SPIKES],[41,:PSYCHIC],[49,:SNATCH],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:IRONDEFENSE],
                     [73,:AMNESIA],[81,:RECOVER],[89,:PSYCHOBOOST],
                     [97,:COUNTER],[97,:MIRRORCOAT]]
   when 3; movelist=[[1,:LEER],[1,:WRAP],[9,:NIGHTSHADE],[17,:DOUBLETEAM],
                     [25,:KNOCKOFF],[33,:PURSUIT],[41,:PSYCHIC],[49,:SWIFT],
                     [57,:PSYCHOSHIFT],[65,:ZENHEADBUTT],[73,:AGILITY],
                     [81,:RECOVER],[89,:PSYCHOBOOST],[97,:EXTREMESPEED]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BURMY,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"getFormOnEnteringBattle"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand ||
         env==PBEnvironment::Rock ||
         env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:WORMADAM,{
"getFormOnCreation"=>proc{|pokemon|
   env=pbGetEnvironment()
   if !pbGetMetadata($game_map.map_id,MetadataOutdoor)
     next 2 # Trash Cloak
   elsif env==PBEnvironment::Sand || env==PBEnvironment::Rock ||
      env==PBEnvironment::Cave
     next 1 # Sandy Cloak
   else
     next 0 # Plant Cloak
   end
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Plant Cloak
   case pokemon.form
   when 1; next getID(PBTypes,:GROUND) # Sandy Cloak
   when 2; next getID(PBTypes,:STEEL)  # Trash Cloak
   end
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0            # Plant Cloak
   case pokemon.form
   when 1; next [60,79,105,36,59, 85] # Sandy Cloak
   when 2; next [60,69, 95,36,69, 95] # Trash Cloak
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0    # Plant Cloak
   case pokemon.form
   when 1; next [0,0,2,0,0,0] # Sandy Cloak
   when 2; next [0,0,1,0,0,1] # Trash Cloak
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                     [23,:CONFUSION],[26,:ROCKBLAST],[29,:HARDEN],[32,:PSYBEAM],
                     [35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],[44,:PSYCHIC],
                     [47,:FISSURE]]
   when 2; movelist=[[1,:TACKLE],[10,:PROTECT],[15,:BUGBITE],[20,:HIDDENPOWER],
                     [23,:CONFUSION],[26,:MIRRORSHOT],[29,:METALSOUND],
                     [32,:PSYBEAM],[35,:CAPTIVATE],[38,:FLAIL],[41,:ATTRACT],
                     [44,:PSYCHIC],[47,:IRONHEAD]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
}
})

MultipleForms.register(:SHELLOS,{
"getFormOnCreation"=>proc{|pokemon|
   maps=[2,5,39,41,44,69]   # Map IDs for second form
   if $game_map && maps.include?($game_map.map_id)
     next 1
   else
     next 0
   end
}
})

MultipleForms.copy(:SHELLOS,:GASTRODON)

MultipleForms.register(:ROTOM,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Normal Form
   next [50,65,107,86,105,107] # All alternate forms
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0             # Normal Form
   case pokemon.form
   when 1; next getID(PBTypes,:FIRE)   # Heat, Microwave
   when 2; next getID(PBTypes,:WATER)  # Wash, Washing Machine
   when 3; next getID(PBTypes,:ICE)    # Frost, Refrigerator
   when 4; next getID(PBTypes,:FLYING) # Fan
   when 5; next getID(PBTypes,:GRASS)  # Mow, Lawnmower
   end
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
   moves=[
      :OVERHEAT,  # Heat, Microwave
      :HYDROPUMP, # Wash, Washing Machine
      :BLIZZARD,  # Frost, Refrigerator
      :AIRSLASH,  # Fan
      :LEAFSTORM  # Mow, Lawnmower
   ]
   hasoldmove=-1
   for i in 0...4
     for j in 0...moves.length
       if isConst?(pokemon.moves[i].id,PBMoves,moves[j])
         hasoldmove=i; break
       end
     end
     break if hasoldmove>=0
   end
   if form>0
     newmove=moves[form-1]
     if newmove!=nil && hasConst?(PBMoves,newmove)
       if hasoldmove>=0
         # Automatically replace the old form's special move with the new one's
         oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
         newmovename=PBMoves.getName(getID(PBMoves,newmove))
         pokemon.moves[hasoldmove]=PBMove.new(getID(PBMoves,newmove))
         Kernel.pbMessage(_INTL("\\se[]1,\\wt[4] 2,\\wt[4] and...\\wt[8] ...\\wt[8] ...\\wt[8] Poof!\\se[balldrop]\1"))
         Kernel.pbMessage(_INTL("{1} forgot how to\r\nuse {2}.\1",pokemon.name,oldmovename))
         Kernel.pbMessage(_INTL("And...\1"))
         Kernel.pbMessage(_INTL("\\se[]{1} learned {2}!\\se[itemlevel]",pokemon.name,newmovename))
       else
         # Try to learn the new form's special move
         pbLearnMove(pokemon,getID(PBMoves,newmove),true)
       end
     end
   else
     if hasoldmove>=0
       # Forget the old form's special move
       oldmovename=PBMoves.getName(pokemon.moves[hasoldmove].id)
       pbDeleteMove(pokemon,hasoldmove)
       Kernel.pbMessage(_INTL("{1} forgot {2}...",pokemon.name,oldmovename))
       if pokemon.moves.find_all{|i| i.id!=0}.length==0
         pbLearnMove(pokemon,getID(PBMoves,:THUNDERSHOCK))
       end
     end
   end
}
})

MultipleForms.register(:GIRATINA,{
"ability"=>proc{|pokemon|
   next if pokemon.form==0           # Altered Forme
   next getID(PBAbilities,:LEVITATE) # Origin Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Altered Forme
   next 6500               # Origin Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0       # Altered Forme
   next [150,120,100,90,120,100] # Origin Forme
},
"getForm"=>proc{|pokemon|
   maps=[49,50,51,72,73]   # Map IDs for Origin Forme
   if isConst?(pokemon.item,PBItems,:GRISEOUSORB) ||
      ($game_map && maps.include?($game_map.map_id))
     next 1
   end
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:SHAYMIN,{
"type2"=>proc{|pokemon|
   next if pokemon.form==0     # Land Forme
   next getID(PBTypes,:FLYING) # Sky Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0              # Land Forme
   next getID(PBAbilities,:SERENEGRACE) # Sky Forme
},
"weight"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next 52                 # Sky Forme
},
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Land Forme
   next [100,103,75,127,120,75] # Sky Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Land Forme
   next [0,0,0,3,0,0]      # Sky Forme
},
"getForm"=>proc{|pokemon|
   next 0 if PBDayNight.isNight?(pbGetTimeNow) ||
             pokemon.hp<=0 || pokemon.status==PBStatuses::FROZEN
   next nil
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:GROWTH],[10,:MAGICALLEAF],[19,:LEECHSEED],
                     [28,:QUICKATTACK],[37,:SWEETSCENT],[46,:NATURALGIFT],
                     [55,:WORRYSEED],[64,:AIRSLASH],[73,:ENERGYBALL],
                     [82,:SWEETKISS],[91,:LEAFSTORM],[100,:SEEDFLARE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:ARCEUS,{
"type1"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"type2"=>proc{|pokemon|
   types=[:NORMAL,:FIGHTING,:FLYING,:POISON,:GROUND,
          :ROCK,:BUG,:GHOST,:STEEL,:QMARKS,
          :FIRE,:WATER,:GRASS,:ELECTRIC,:PSYCHIC,
          :ICE,:DRAGON,:DARK]
   next getID(PBTypes,types[pokemon.form])
},
"getForm"=>proc{|pokemon|
   next 1  if isConst?(pokemon.item,PBItems,:FISTPLATE)
   next 2  if isConst?(pokemon.item,PBItems,:SKYPLATE)
   next 3  if isConst?(pokemon.item,PBItems,:TOXICPLATE)
   next 4  if isConst?(pokemon.item,PBItems,:EARTHPLATE)
   next 5  if isConst?(pokemon.item,PBItems,:STONEPLATE)
   next 6  if isConst?(pokemon.item,PBItems,:INSECTPLATE)
   next 7  if isConst?(pokemon.item,PBItems,:SPOOKYPLATE)
   next 8  if isConst?(pokemon.item,PBItems,:IRONPLATE)
   next 10 if isConst?(pokemon.item,PBItems,:FLAMEPLATE)
   next 11 if isConst?(pokemon.item,PBItems,:SPLASHPLATE)
   next 12 if isConst?(pokemon.item,PBItems,:MEADOWPLATE)
   next 13 if isConst?(pokemon.item,PBItems,:ZAPPLATE)
   next 14 if isConst?(pokemon.item,PBItems,:MINDPLATE)
   next 15 if isConst?(pokemon.item,PBItems,:ICICLEPLATE)
   next 16 if isConst?(pokemon.item,PBItems,:DRACOPLATE)
   next 17 if isConst?(pokemon.item,PBItems,:DREADPLATE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BASCULIN,{
"getFormOnCreation"=>proc{|pokemon|
   next rand(2)
},
"wildHoldItems"=>proc{|pokemon|
   next if pokemon.form==0                 # Red-Striped
   next [0,getID(PBItems,:DEEPSEASCALE),0] # Blue-Striped
}
})

MultipleForms.register(:DARMANITAN,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next [105,30,105,55,140,105] # Zen Mode
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0      # Standard Mode
   next getID(PBTypes,:PSYCHIC) # Zen Mode
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Standard Mode
   next [0,0,0,0,2,0]      # Zen Mode
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:DEERLING,{
"getForm"=>proc{|pokemon|
   time=pbGetTimeNow
   next (time.month-1)%4
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.copy(:DEERLING,:SAWSBUCK)

MultipleForms.register(:TORNADUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,100,80,121,110,90] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0                # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:REGENERATOR) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,3,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:THUNDURUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Incarnate Forme
   next [79,105,70,101,145,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:VOLTABSORB) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,0,0,0,3,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:LANDORUS,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0    # Incarnate Forme
   next [89,145,90,71,105,80] # Therian Forme
},
"ability"=>proc{|pokemon|
   next if pokemon.form==0               # Incarnate Forme
   if pokemon.abilityflag && pokemon.abilityflag!=2
     next getID(PBAbilities,:INTIMIDATE) # Therian Forme
   end
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Incarnate Forme
   next [0,3,0,0,0,0]      # Therian Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KYUREM,{
"getBaseStats"=>proc{|pokemon|
   case pokemon.form
   when 1; next [125,120, 90,95,170,100] # White Kyurem
   when 2; next [125,170,100,95,120, 90] # Black Kyurem
   else;   next                          # Kyurem
   end
},
"ability"=>proc{|pokemon|
   case pokemon.form
   when 1; next getID(PBAbilities,:TURBOBLAZE) # White Kyurem
   when 2; next getID(PBAbilities,:TERAVOLT)   # Black Kyurem
   else;   next                                # Kyurem
   end
},
"evYield"=>proc{|pokemon|
   case pokemon.form
   when 1; next [0,0,0,0,3,0] # White Kyurem
   when 2; next [0,3,0,0,0,0] # Black Kyurem
   else;   next               # Kyurem
   end
},
"getMoveList"=>proc{|pokemon|
   next if pokemon.form==0
   movelist=[]
   case pokemon.form
   when 1; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                     [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                     [36,:SLASH],[43,:FUSIONFLARE],[50,:ICEBURN],
                     [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                     [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   when 2; movelist=[[1,:ICYWIND],[1,:DRAGONRAGE],[8,:IMPRISON],
                     [15,:ANCIENTPOWER],[22,:ICEBEAM],[29,:DRAGONBREATH],
                     [36,:SLASH],[43,:FUSIONBOLT],[50,:FREEZESHOCK],
                     [57,:DRAGONPULSE],[64,:IMPRISON],[71,:ENDEAVOR],
                     [78,:BLIZZARD],[85,:OUTRAGE],[92,:HYPERVOICE]]
   end
   for i in movelist
     i[1]=getConst(PBMoves,i[1])
   end
   next movelist
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:KELDEO,{
"getForm"=>proc{|pokemon|
   next 1 if pokemon.knowsMove?(:SECRETSWORD) # Resolute Form
   next 0                                     # Ordinary Form
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:MELOETTA,{
"getBaseStats"=>proc{|pokemon|
   next if pokemon.form==0     # Aria Forme
   next [100,128,90,128,77,77] # Pirouette Forme
},
"type2"=>proc{|pokemon|
   next if pokemon.form==0       # Aria Forme
   next getID(PBTypes,:FIGHTING) # Pirouette Forme
},
"evYield"=>proc{|pokemon|
   next if pokemon.form==0 # Aria Forme
   next [0,1,1,1,0,0]      # Pirouette Forme
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:GENESECT,{
"getForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:SHOCKDRIVE)
   next 2 if isConst?(pokemon.item,PBItems,:BURNDRIVE)
   next 3 if isConst?(pokemon.item,PBItems,:CHILLDRIVE)
   next 4 if isConst?(pokemon.item,PBItems,:DOUSEDRIVE)
   next 0
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

##### Mega Evolution forms #####################################################

MultipleForms.register(:VENUSAUR,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:VENUSAURITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Venusaur") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [80,100,123,80,122,120] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:THICKFAT) if pokemon.form==1
   next
},
"height"=>proc{|pokemon|
   next 24 if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1555 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:CHARIZARD,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:CHARIZARDITEX)
   next 2 if isConst?(pokemon.item,PBItems,:CHARIZARDITEY)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Charizard X") if pokemon.form==1
   next _INTL("Mega Charizard Y") if pokemon.form==2
   next
},
"getBaseStats"=>proc{|pokemon|
   next [78,130,111,100,130,85] if pokemon.form==1
   next [78,104,78,100,159,115] if pokemon.form==2
   next
},
"type2"=>proc{|pokemon|
   next getID(PBTypes,:DRAGON) if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:TOUGHCLAWS) if pokemon.form==1
   next getID(PBAbilities,:DROUGHT) if pokemon.form==2
   next
},
"weight"=>proc{|pokemon|
   next 1105 if pokemon.form==1
   next 1005 if pokemon.form==2
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})

MultipleForms.register(:BLASTOISE,{
"getMegaForm"=>proc{|pokemon|
   next 1 if isConst?(pokemon.item,PBItems,:BLASTOISINITE)
   next
},
"getUnmegaForm"=>proc{|pokemon|
   next 0
},
"getMegaName"=>proc{|pokemon|
   next _INTL("Mega Blastoise") if pokemon.form==1
   next
},
"getBaseStats"=>proc{|pokemon|
   next [79,103,120,78,135,115] if pokemon.form==1
   next
},
"ability"=>proc{|pokemon|
   next getID(PBAbilities,:MEGALAUNCHER) if pokemon.form==1
   next
},
"weight"=>proc{|pokemon|
   next 1011 if pokemon.form==1
   next
},
"onSetForm"=>proc{|pokemon,form|
   pbSeenForm(pokemon)
}
})