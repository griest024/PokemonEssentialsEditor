#===============================================================================
# Filename:    rgss_mod.rb
#
# Developer:   Raku (rakudayo@gmail.com)
#
# Description: This file is for any changes that may have been made directly to
#    the RPG module.  Ideally, no one should need to do this, since there are
#    the Game_* classes, but in case you did modify any classes in the RPG
#    module, you need to add those changes here for the importer exporter to
#    work.
#
#    This is required because the Marshal class needs to know the exact data
#    footprint of all the classes in the RPG module.  If new attributes are 
#    added, then the Marshal class with fail loading them from the .rxdata file.
#===============================================================================

# Add any additional classes saved out in the rxdata files here...

# Adds PKMN Essentials classes. TODO: Do this dynamically

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

class PokeBattle_Trainer
  attr_accessor(:name)
  attr_accessor(:id)
  attr_accessor(:metaID)
  attr_accessor(:trainertype)
  attr_accessor(:outfit)
  attr_accessor(:badges)
  attr_accessor(:money)
  attr_accessor(:seen)
  attr_accessor(:owned)
  attr_accessor(:formseen)
  attr_accessor(:formlastseen)
  attr_accessor(:shadowcaught)
  attr_accessor(:party)
  attr_accessor(:pokedex)    # Whether the Pokédex was obtained
  attr_accessor(:pokegear)   # Whether the Pokégear was obtained
  attr_accessor(:language)
  attr_accessor(:mysterygiftaccess)   # Whether MG can be used from load screen
  attr_accessor(:mysterygift)         # Variable that stores downloaded MG data


  def initialize(name,trainertype)
    @name=name
    @language=pbGetLanguage()
    @trainertype=trainertype
    @id=rand(256)
    @id|=rand(256)<<8
    @id|=rand(256)<<16
    @id|=rand(256)<<24
    @metaID=0
    @outfit=0
    @pokegear=false
    @pokedex=false
    clearPokedex
    @shadowcaught=[]
    for i in 1..PBSpecies.maxValue
      @shadowcaught[i]=false
    end
    @badges=[]
    for i in 0...8
      @badges[i]=false
    end
    @money=INITIALMONEY
    @party=[]
  end
end

class PBAnimations < Array
  include Enumerable
  attr_reader :array
  attr_accessor :selected

  def initialize(size=1)
    @array=[]
    @selected=0
    size=1 if size<1 # Always create at least one animation
    size.times do
      @array.push(PBAnimation.new)
    end
  end
end

class PBAnimation < Array
  include Enumerable
  attr_accessor :graphic
  attr_accessor :hue 
  attr_accessor :name
  attr_accessor :position
  attr_accessor :speed
  attr_reader :array
  attr_reader :timing
  attr_accessor :id
  MAXSPRITES=30

  def initialize(size=1)
    @array=[]
    @timing=[]
    @name=""
    @id=-1
    @graphic=""
    @hue=0
    @scope=0
    @position=4 # 1=target, 2=user, 3=user and target, 4=screen
    size=1 if size<1 # Always create at least one frame
    size.times do
      addFrame
    end
  end
end

class PBAnimTiming
  attr_accessor :frame
  attr_accessor :timingType   # 0=play SE, 1=set bg, 2=bg mod
  attr_accessor :name         # Name of SE file or BG file
  attr_accessor :volume
  attr_accessor :pitch
  attr_accessor :bgX          # x coordinate of bg (or to move bg to)
  attr_accessor :bgY          # y coordinate of bg (or to move bg to)
  attr_accessor :opacity      # Opacity of bg (or to change bg to)
  attr_accessor :colorRed     # Color of bg (or to change bg to)
  attr_accessor :colorGreen   # Color of bg (or to change bg to)
  attr_accessor :colorBlue    # Color of bg (or to change bg to)
  attr_accessor :colorAlpha   # Color of bg (or to change bg to)
  attr_accessor :duration     # How long to spend changing to the new bg coords/color
  attr_accessor :flashScope
  attr_accessor :flashColor
  attr_accessor :flashDuration

  def initialize(type=0)
    @frame=0
    @timingType=type
    @name=""
    @volume=80
    @pitch=100
    @bgX=nil
    @bgY=nil
    @opacity=nil
    @colorRed=nil
    @colorGreen=nil
    @colorBlue=nil
    @colorAlpha=nil
    @duration=5
    @flashScope=0
    @flashColor=Color.new(255,255,255,255)
    @flashDuration=5
  end
end

class PokemonDataCopy
  attr_accessor :dataOldHash
  attr_accessor :dataNewHash
  attr_accessor :dataTime
  attr_accessor :data

  def initialize(data,datasave)
    @datafile=data
    @datasave=datasave
    @data=readfile(@datafile)
    @dataOldHash=crc32(@data)
    @dataTime=filetime(@datafile)
  end
end
