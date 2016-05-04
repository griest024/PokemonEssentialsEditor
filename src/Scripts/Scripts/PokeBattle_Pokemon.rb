# This class stores data on each Pokemon.  Refer to $Trainer.party for an array
# of each Pokemon in the Trainer's current party.
class PokeBattle_Pokemon
  attr_reader(:totalhp)       # Current Total HP
  attr_reader(:attack)        # Current Attack stat
  attr_reader(:defense)       # Current Defense stat
  attr_reader(:speed)         # Current Speed stat
  attr_reader(:spatk)         # Current Special Attack stat
  attr_reader(:spdef)         # Current Special Defense stat
  attr_accessor(:iv)          # Array of 6 Individual Values for HP, Atk, Def,
                              #    Speed, Sp Atk, and Sp Def
  attr_accessor(:ev)          # Effort Values
  attr_accessor(:species)     # Species (National Pokedex number)
  attr_accessor(:personalID)  # Personal ID
  attr_accessor(:trainerID)   # 32-bit Trainer ID (the secret ID is in the upper
                              #    16 bits)
  attr_accessor(:hp)          # Current HP
  attr_accessor(:pokerus)     # Pokérus strain and infection time
  attr_accessor(:item)        # Held item
  attr_accessor(:itemRecycle) # Consumed held item (used in battle only)
  attr_accessor(:itemInitial) # Resulting held item (used in battle only)
  attr_accessor(:mail)        # Mail
  attr_accessor(:fused)       # The Pokémon fused into this one
  attr_accessor(:name)        # Nickname
  attr_accessor(:exp)         # Current experience points
  attr_accessor(:happiness)   # Current happiness
  attr_accessor(:status)      # Status problem (PBStatuses) 
  attr_accessor(:statusCount) # Sleep count/Toxic flag
  attr_accessor(:eggsteps)    # Steps to hatch egg, 0 if Pokémon is not an egg
  attr_accessor(:moves)       # Moves (PBMove)
  attr_accessor(:firstmoves)  # The moves known when this Pokémon was obtained
  attr_accessor(:ballused)    # Ball used
  attr_accessor(:markings)    # Markings
  attr_accessor(:obtainMode)  # Manner obtained:
                              #    0 - met, 1 - as egg, 2 - traded,
                              #    4 - fateful encounter
  attr_accessor(:obtainMap)   # Map where obtained
  attr_accessor(:obtainText)  # Replaces the obtain map's name if not nil
  attr_accessor(:obtainLevel) # Level obtained
  attr_accessor(:hatchedMap)  # Map where an egg was hatched
  attr_accessor(:language)    # Language
  attr_accessor(:ot)          # Original Trainer's name 
  attr_accessor(:otgender)    # Original Trainer's gender:
                              #    0 - male, 1 - female, 2 - mixed, 3 - unknown
                              #    For information only, not used to verify
                              #    ownership of the Pokemon
  attr_accessor(:abilityflag) # Forces the first/second/hidden (0/1/2) ability
  attr_accessor(:genderflag)  # Forces male (0) or female (1)
  attr_accessor(:natureflag)  # Forces a particular nature
  attr_accessor(:shinyflag)   # Forces the shininess (true/false)
  attr_accessor(:ribbons)     # Array of ribbons
  attr_accessor :cool,:beauty,:cute,:smart,:tough,:sheen # Contest stats

################################################################################
# Ownership, obtained information
################################################################################
# Returns the gender of this Pokémon's original trainer (2=unknown).
  def otgender
    @otgender=2 if !@otgender
    return @otgender
  end

# Returns whether the specified Trainer is NOT this Pokemon's original trainer.
  def isForeign?(trainer)
    return @trainerID!=trainer.id || @ot!=trainer.name
  end

# Returns the public portion of the original trainer's ID.
  def publicID
    return @trainerID&0xFFFF
  end

# Returns this Pokémon's level when this Pokémon was obtained.
  def obtainLevel
    @obtainLevel=0 if !@obtainLevel
    return @obtainLevel
  end

# Returns the time when this Pokémon was obtained.
  def timeReceived
    return @timeReceived ? Time.at(@timeReceived) : Time.gm(2000)
  end

# Sets the time when this Pokémon was obtained.
  def timeReceived=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeReceived=value.to_i
    else
      @timeReceived=value
    end
  end

# Returns the time when this Pokémon hatched.
  def timeEggHatched
    if obtainMode==1
      return @timeEggHatched ? Time.at(@timeEggHatched) : Time.gm(2000)
    else
      return Time.gm(2000)
    end
  end

# Sets the time when this Pokémon hatched.
  def timeEggHatched=(value)
    # Seconds since Unix epoch
    if value.is_a?(Time)
      @timeEggHatched=value.to_i
    else
      @timeEggHatched=value
    end
  end

################################################################################
# Level
################################################################################
# Returns this Pokemon's level.
  def level
    return PBExperience.pbGetLevelFromExperience(@exp,self.growthrate)
  end

# Sets this Pokemon's level by changing its Exp. Points.
  def level=(value)
    if value<1 || value>PBExperience::MAXLEVEL
      raise ArgumentError.new(_INTL("The level number ({1}) is invalid.",value))
    end
    self.exp=PBExperience.pbGetStartExperience(value,self.growthrate) 
  end

# Returns whether this Pokemon is an egg.
  def isEgg?
    return @eggsteps>0
  end
  
  def egg?; return isEgg?; end   # DEPRECATED

# Returns this Pokemon's growth rate.
  def growthrate
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,20)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns this Pokemon's base Experience value.
  def baseExp
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,38)
    ret=dexdata.fgetw
    dexdata.close
    return ret
  end

################################################################################
# Gender
################################################################################
# Returns this Pokemon's gender. 0=male, 1=female, 2=genderless
  def gender
    return @genderflag if @genderflag!=nil
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    case genderbyte
    when 255
      return 2 # genderless
    when 254
      return 1 # always female
    else
      lowbyte=@personalID&0xFF
      return PokeBattle_Pokemon.isFemale(lowbyte,genderbyte) ? 1 : 0
    end
  end

# Helper function that determines whether the input values would make a female.
  def self.isFemale(b,genderRate)
    return true if genderRate==254    # AlwaysFemale
    return false if genderRate==255   # Genderless
    return b<=genderRate
  end

# Returns whether this Pokémon is male.
  def isMale?
    return self.gender==0
  end

# Returns whether this Pokémon is female.
  def isFemale?
    return self.gender==1
  end

# Sets this Pokémon's gender to a particular gender (if possible).
  def setGender(value)
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,18)
    genderbyte=dexdata.fgetb
    dexdata.close
    if genderbyte!=255 && genderbyte!=0 && genderbyte!=254
      @genderflag=value
    end
  end

  def makeMale; setGender(0); end
  def makeFemale; setGender(1); end

################################################################################
# Ability
################################################################################
# Returns the index of this Pokémon's ability.
  def abilityIndex
    abil=@abilityflag!=nil ? @abilityflag : (@personalID&1)
    return abil
  end

# Returns the ID of this Pokemon's ability.
  def ability
    abil=abilityIndex
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    ret1=dexdata.fgetb
    ret2=dexdata.fgetb
    pbDexDataOffset(dexdata,@species,40)
    h1=dexdata.fgetb
    h2=dexdata.fgetb
    h3=dexdata.fgetb
    h4=dexdata.fgetb
    dexdata.close
    ret=ret1
    if abil==2
      return h1 if h1>0
      abil=(@personalID&1)
    elsif abil==3
      return h2 if h2>0
      abil=(@personalID&1)
    elsif abil==4
      return h3 if h3>0
      abil=(@personalID&1)
    elsif abil==5
      return h4 if h4>0
      abil=(@personalID&1)
    end
    if abil==1
      ret=ret2
      ret=ret1 if ret2==0
    end
    return ret
  end

# Sets this Pokémon's ability to a particular ability (if possible).
  def setAbility(value)
    @abilityflag=value
  end

# Returns the list of abilities this Pokémon can have.
  def getAbilityList
    abils=[]; ret=[[],[]]
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,29)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    pbDexDataOffset(dexdata,@species,40)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    abils.push(dexdata.fgetb)
    dexdata.close
    for i in 0...abils.length
      next if !abils[i] || abils[i]<=0
      ret[0].push(abils[i]); ret[1].push(i)
    end
    return ret
  end

################################################################################
# Nature
################################################################################
# Returns the ID of this Pokémon's nature.
  def nature
    return @natureflag if @natureflag!=nil
    return @personalID%25
  end

# Sets this Pokémon's nature to a particular nature.
  def setNature(value)
    if value.is_a?(String) || value.is_a?(Symbol)
      value=getID(PBNatures,value)
    end
    @natureflag=value
    self.calcStats
  end

################################################################################
# Shininess
################################################################################
# Returns whether this Pokemon is shiny (differently colored).
  def isShiny?
    return @shinyflag if @shinyflag!=nil
    a=@personalID^@trainerID
    b=a&0xFFFF
    c=(a>>16)&0xFFFF
    d=b^c
    return (d<SHINYPOKEMONCHANCE)
  end

# Makes this Pokemon shiny.
  def makeShiny
    @shinyflag=true
  end

# Makes this Pokemon not shiny.
  def makeNotShiny
    @shinyflag=false
  end

################################################################################
# Pokérus
################################################################################
# Gives this Pokemon Pokérus (either the specified strain or a random one).
  def givePokerus(strain=0)
    return if self.pokerusStage==2 # Can't re-infect a cured Pokémon
    if strain<=0 || strain>=16
      strain=1+rand(15)
    end
    time=1+(strain%4)
    @pokerus=time
    @pokerus|=strain<<4
  end

# Resets the infection time for this Pokemon's Pokérus (even if cured).
  def resetPokerusTime
    return if @pokerus==0
    strain=@pokerus%16
    time=1+(strain%4)
    @pokerus=time
    @pokerus|=strain<<4
  end

# Reduces the time remaining for this Pokemon's Pokérus (if infected).
  def lowerPokerusCount
    return if self.pokerusStage!=1
    @pokerus-=1
  end

# Returns the Pokérus infection stage for this Pokemon.
  def pokerusStage
    return 0 if !@pokerus || @pokerus==0        # Not infected
    return 2 if @pokerus>0 && (@pokerus%16)==0  # Cured
    return 1                                    # Infected
  end

################################################################################
# Types
################################################################################
# Returns whether this Pokémon has the specified type.
  def hasType?(type)
    if type.is_a?(String) || type.is_a?(Symbol)
      return isConst?(self.type1,PBTypes,type) || isConst?(self.type2,PBTypes,type)
    else
      return self.type1==type || self.type2==type
    end
  end

# Returns this Pokémon's first type.
  def type1
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,8)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

# Returns this Pokémon's second type.
  def type2
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,9)
    ret=dexdata.fgetb
    dexdata.close
    return ret
  end

################################################################################
# Moves
################################################################################
# Returns the number of moves known by the Pokémon.
  def numMoves
    ret=0
    for i in 0...4
      ret+=1 if @moves[i].id!=0
    end
    return ret
  end

# Returns true if the Pokémon knows the given move.
  def knowsMove?(move)
    if move.is_a?(String) || move.is_a?(Symbol)
      move=getID(PBMoves,move)
    end
    return false if !move || move<=0
    for i in 0...4
      return true if @moves[i].id==move
    end
    return false
  end

# Returns the list of moves this Pokémon can learn by levelling up.
  def getMoveList
    movelist=[]
    atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
    offset=atkdata.getOffset(@species-1)
    length=atkdata.getLength(@species-1)>>1
    atkdata.pos=offset
    for k in 0..length-1
      level=atkdata.fgetw
      move=atkdata.fgetw
      movelist.push([level,move])
    end
    atkdata.close
    return movelist
  end

# Sets this Pokémon's movelist to the default movelist it originally had.
  def resetMoves
    moves=self.getMoveList
    movelist=[]
    for i in moves
      if i[0]<=self.level
        movelist[movelist.length]=i[1]
      end
    end
    movelist|=[] # Remove duplicates
    listend=movelist.length-4
    listend=0 if listend<0
    j=0
    for i in listend...listend+4
      moveid=(i>=movelist.length) ? 0 : movelist[i]
      @moves[j]=PBMove.new(moveid)
      j+=1
    end
  end

# Silently learns the given move. Will erase the first known move if it has to.
  def pbLearnMove(move)
    if move.is_a?(String) || move.is_a?(Symbol)
      move=getID(PBMoves,move)
    end
    return if move<=0
    for i in 0...4
      if @moves[i].id==move
        j=i+1; while j<4
          break if @moves[j].id==0
          tmp=@moves[j]
          @moves[j]=@moves[j-1]
          @moves[j-1]=tmp
          j+=1
        end
        return
      end
    end
    for i in 0...4
      if @moves[i].id==0
        @moves[i]=PBMove.new(move)
        return
      end
    end
    @moves[0]=@moves[1]
    @moves[1]=@moves[2]
    @moves[2]=@moves[3]
    @moves[3]=PBMove.new(move)
  end

# Deletes the given move from the Pokémon.
  def pbDeleteMove(move)
    if move.is_a?(String) || move.is_a?(Symbol)
      move=getID(PBMoves,move)
    end
    return if !move || move<=0
    newmoves=[]
    for i in 0...4
      newmoves.push(@moves[i]) if @moves[i].id!=move
    end
    newmoves.push(PBMove.new(0))
    for i in 0...4
      @moves[i]=newmoves[i]
    end
  end

# Deletes the move at the given index from the Pokémon.
  def pbDeleteMoveAtIndex(index)
    newmoves=[]
    for i in 0...4
      newmoves.push(@moves[i]) if i!=index
    end
    newmoves.push(PBMove.new(0))
    for i in 0...4
      @moves[i]=newmoves[i]
    end
  end

# Deletes all moves from the Pokémon.
  def pbDeleteAllMoves
    for i in 0...4
      @moves[i]=PBMove.new(0)
    end
  end

# Copies currently known moves into a separate array, for Move Relearner.
  def pbRecordFirstMoves
    @firstmoves=[]
    for i in 0...4
      @firstmoves.push(@moves[i].id) if @moves[i].id>0
    end
  end

################################################################################
# Contest attributes, ribbons
################################################################################
  def cool; @cool ? @cool : 0; end
  def beauty; @beauty ? @beauty : 0; end
  def cute; @cute ? @cute : 0; end
  def smart; @smart ? @smart : 0; end
  def tough; @tough ? @tough : 0; end
  def sheen; @sheen ? @sheen : 0; end

# Returns the number of ribbons this Pokemon has.
  def ribbonCount
    @ribbons=[] if !@ribbons
    return @ribbons.length
  end

# Returns whether this Pokémon has the specified ribbon.
  def hasRibbon?(ribbon) 
    @ribbons=[] if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return false if ribbon==0
    return @ribbons.include?(ribbon)
  end

# Gives this Pokémon the specified ribbon.
  def giveRibbon(ribbon)
    @ribbons=[] if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return if ribbon==0
    @ribbons.push(ribbon) if !@ribbons.include?(ribbon)
  end

# Replaces one ribbon with the next one along, if possible.
  def upgradeRibbon(*arg)
    @ribbons=[] if !@ribbons
    for i in 0...arg.length-1
      for j in 0...@ribbons.length
        thisribbon=(arg[i].is_a?(Integer)) ? arg[i] : getID(PBRibbons,arg[i])
        if @ribbons[j]==thisribbon
          nextribbon=(arg[i+1].is_a?(Integer)) ? arg[i+1] : getID(PBRibbons,arg[i+1])
          @ribbons[j]=nextribbon
          return nextribbon
        end
      end
    end
    if !hasRibbon?(arg[arg.length-1])
      firstribbon=(arg[0].is_a?(Integer)) ? arg[0] : getID(PBRibbons,arg[0])
      giveRibbon(firstribbon)
      return firstribbon
    end
    return 0
  end

# Removes the specified ribbon from this Pokémon.
  def takeRibbon(ribbon)
    return if !@ribbons
    ribbon=getID(PBRibbons,ribbon) if !ribbon.is_a?(Integer)
    return if ribbon==0
    for i in 0...@ribbons.length
      if @ribbons[i]==ribbon
        @ribbons[i]=nil; break
      end
    end
    @ribbons.compact!
  end

# Removes all ribbons from this Pokémon.
  def clearAllRibbons
    @ribbons=[]
  end

################################################################################
# Other
################################################################################
# Returns whether this Pokémon has a hold item.
  def hasItem?(value=0)
    if value==0
      return self.item>0
    else
      if value.is_a?(String) || value.is_a?(Symbol)
        value=getID(PBItems,value)
      end
      return self.item==value
    end
    return false
  end

# Sets this Pokémon's item. Accepts symbols.
  def setItem(value)
    if value.is_a?(String) || value.is_a?(Symbol)
      value=getID(PBItems,value)
    end
    self.item=value
  end

# Returns the items this species can be found holding in the wild.
  def wildHoldItems
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,48)
    itemcommon=dexdata.fgetw
    itemuncommon=dexdata.fgetw
    itemrare=dexdata.fgetw
    dexdata.close
    itemcommon=0 if !itemcommon
    itemuncommon=0 if !itemuncommon
    itemrare=0 if !itemrare
    return [itemcommon,itemuncommon,itemrare]
  end

# Returns this Pokémon's mail.
  def mail
    return nil if !@mail
    if @mail.item==0 || !self.hasItem? || @mail.item!=self.item
      @mail=nil
      return nil
    end
    return @mail
  end

# Returns this Pokémon's language.
  def language; @language ? @language : 0; end

# Returns the markings this Pokémon has.
  def markings
    @markings=0 if !@markings
    return @markings
  end

# Returns a string stating the Unown form of this Pokémon.
  def unownShape
    return "ABCDEFGHIJKLMNOPQRSTUVWXYZ?!"[@form,1]
  end

# Returns the weight of this Pokémon.
  def weight
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,35)
    weight=dexdata.fgetw
    dexdata.close
    return weight
  end

# Returns the EV yield of this Pokémon.
  def evYield
    ret=[]
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,23)
    for i in 0...6
      v=dexdata.fgetb
      v=0 if !v
      ret.push(v)
    end
    dexdata.close
    return ret
  end

# Sets this Pokémon's HP.
  def hp=(value)
    value=0 if value<0
    @hp=value
    if @hp==0
      @status=0
      @statusCount=0
    end
  end

# Heals all HP of this Pokémon.
  def healHP
    return if egg?
    @hp=@totalhp
  end

# Heals the status problem of this Pokémon.
  def healStatus
    return if egg?
    @status=0
    @statusCount=0
  end

# Heals all PP of this Pokémon.
  def healPP(index=-1)
    return if egg?
    if index>=0
      @moves[index].pp=@moves[index].totalpp
    else
      for i in 0...4
        @moves[i].pp=@moves[i].totalpp
      end
    end
  end

# Heals all HP, PP, and status problems of this Pokémon.
  def heal
    return if egg?
    healHP
    healStatus
    healPP
  end

# Changes the happiness of this Pokémon depending on what happened to change it.
  def changeHappiness(method)
    gain=0; luxury=false
    case method
    when "walking"
      gain=1
      gain+=1 if @happiness<200
      gain+=1 if @obtainMap==$game_map.map_id
      luxury=true
    when "level up"
      gain=2
      gain=3 if @happiness<200
      gain=5 if @happiness<100
      luxury=true
    when "groom"
      gain=4
      gain=10 if @happiness<200
      luxury=true
    when "faint"
      gain=-1
    when "vitamin"
      gain=2
      gain=3 if @happiness<200
      gain=5 if @happiness<100
    when "EV berry"
      gain=2
      gain=5 if @happiness<200
      gain=10 if @happiness<100
    when "powder"
      gain=-10
      gain=-5 if @happiness<200
    when "Energy Root"
      gain=-15
      gain=-10 if @happiness<200
    when "Revival Herb"
      gain=-20
      gain=-15 if @happiness<200
    else
      Kernel.pbMessage(_INTL("Unknown happiness-changing method."))
    end
    gain+=1 if luxury && self.ballused==pbGetBallType(:LUXURYBALL)
    if isConst?(self.item,PBItems,:SOOTHEBELL) && gain>0
      gain=(gain*3.0/2).round
    end
    @happiness+=gain
    @happiness=[[255,@happiness].min,0].max
  end

################################################################################
# Stat calculations, Pokémon creation
################################################################################
# Returns this Pokémon's base stats.  An array of six values.
  def baseStats
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,10)
    ret=[
       dexdata.fgetb, # HP
       dexdata.fgetb, # Attack
       dexdata.fgetb, # Defense
       dexdata.fgetb, # Speed
       dexdata.fgetb, # Special Attack
       dexdata.fgetb  # Special Defense
    ]
    dexdata.close
    return ret
  end

# Returns the maximum HP of this Pokémon.
  def calcHP(base,level,iv,ev)
    return 1 if base==1
    return ((base*2+iv+(ev>>2))*level/100).floor+level+10
  end

# Returns the specified stat of this Pokémon (not used for total HP).
  def calcStat(base,level,iv,ev,pv)
    return ((((base*2+iv+(ev>>2))*level/100).floor+5)*pv/100).floor
  end

# Recalculates this Pokémon's stats.
  def calcStats
    nature=self.nature
    stats=[]
    pvalues=[100,100,100,100,100]
    nd5=(nature/5).floor
    nm5=(nature%5).floor
    if nd5!=nm5
      pvalues[nd5]=110
      pvalues[nm5]=90
    end
    level=self.level
    bs=self.baseStats
    for i in 0..5
      base=bs[i]
      if i==PBStats::HP
        stats[i]=calcHP(base,level,@iv[i],@ev[i])
      else
        stats[i]=calcStat(base,level,@iv[i],@ev[i],pvalues[i-1])
      end
    end
    diff=@totalhp-@hp
    @totalhp=stats[0]
    if @hp>0
      @hp=@totalhp-diff
      @hp=1 if @hp<=0
      @hp=@totalhp if @hp>@totalhp
    end
    @attack=stats[1]
    @defense=stats[2]
    @speed=stats[3]
    @spatk=stats[4]
    @spdef=stats[5]
  end

# Creates a new Pokémon object.
#    species   - Pokémon species.
#    level     - Pokémon level.
#    player    - PokeBattle_Trainer object for the original trainer.
#    withMoves - If false, this Pokémon has no moves.
  def initialize(species,level,player=nil,withMoves=true)
    if species.is_a?(String) || species.is_a?(Symbol)
      species=getID(PBSpecies,species)
    end
    cname=getConstantName(PBSpecies,species) rescue nil
    if !species || species<1 || species>PBSpecies.maxValue || !cname
      raise ArgumentError.new(_INTL("The species number (no. {1} of {2}) is invalid.",
         species,PBSpecies.maxValue))
      return nil
    end
    time=pbGetTimeNow
    @timeReceived=time.getgm.to_i # Use GMT
    @species=species
    # Individual Values
    @personalID=rand(256)
    @personalID|=rand(256)<<8
    @personalID|=rand(256)<<16
    @personalID|=rand(256)<<24
    @hp=1
    @totalhp=1
    @ev=[0,0,0,0,0,0]
    @iv=[]
    @iv[0]=rand(32)
    @iv[1]=rand(32)
    @iv[2]=rand(32)
    @iv[3]=rand(32)
    @iv[4]=rand(32)
    @iv[5]=rand(32)
    if player
      @trainerID=player.id
      @ot=player.name
      @otgender=player.gender
      @language=player.language
    else
      @trainerID=0
      @ot=""
      @otgender=2
    end
    dexdata=pbOpenDexData
    pbDexDataOffset(dexdata,@species,19)
    @happiness=dexdata.fgetb
    dexdata.close
    @name=PBSpecies.getName(@species)
    @eggsteps=0
    @status=0
    @statusCount=0
    @item=0
    @mail=nil
    @fused=nil
    @ribbons=[]
    @moves=[]
    self.ballused=0
    self.level=level
    calcStats
    @hp=@totalhp
    if $game_map
      @obtainMap=$game_map.map_id
      @obtainText=nil
      @obtainLevel=level
    else
      @obtainMap=0
      @obtainText=nil
      @obtainLevel=level
    end
    @obtainMode=0   # Met
    @obtainMode=4 if $game_switches && $game_switches[FATEFUL_ENCOUNTER_SWITCH]
    @hatchedMap=0
    if withMoves
      atkdata=pbRgssOpen("Data/attacksRS.dat","rb")
      offset=atkdata.getOffset(species-1)
      length=atkdata.getLength(species-1)>>1
      atkdata.pos=offset
      # Generating move list
      movelist=[]
      for i in 0..length-1
        alevel=atkdata.fgetw
        move=atkdata.fgetw
        if alevel<=level
          movelist[movelist.length]=move
        end
      end
      atkdata.close
      movelist|=[] # Remove duplicates
      # Use the last 4 items in the move list
      listend=movelist.length-4
      listend=0 if listend<0
      j=0
      for i in listend...listend+4
        moveid=(i>=movelist.length) ? 0 : movelist[i]
        @moves[j]=PBMove.new(moveid)
        j+=1
      end
    end
  end
end