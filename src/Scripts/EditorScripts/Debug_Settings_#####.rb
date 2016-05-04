#===============================================================================
# All script sections are direct copies of those in the main program, with the
# exception of the ones with ##### after their name which are exclusive to the
# External Editor.
#===============================================================================
$DEBUG=true; $TEST=true; $INEDITOR=true

DEFAULTSCREENWIDTH   = 640
DEFAULTSCREENHEIGHT  = 480
DEFAULTSCREENZOOM    = 1.0
MAXIMUMLEVEL         = 100
EGGINITIALLEVEL      = 1
SHINYPOKEMONCHANCE   = 8
INITIALMONEY         = 3000
MAXMONEY             = 999999
RIVALNAMES           = []
USEKEYBOARDTEXTENTRY = false
LANGUAGES            = []

#===============================================================================
# The following is taken from PField_Field.
#===============================================================================
module PBMoveRoute
  Down               = 1
  Left               = 2
  Right              = 3
  Up                 = 4
  LowerLeft          = 5
  LowerRight         = 6
  UpperLeft          = 7
  UpperRight         = 8
  Random             = 9
  TowardPlayer       = 10
  AwayFromPlayer     = 11
  Forward            = 12
  Backward           = 13
  Jump               = 14 # xoffset, yoffset
  Wait               = 15 # frames
  TurnDown           = 16
  TurnLeft           = 17
  TurnRight          = 18
  TurnUp             = 19
  TurnRight90        = 20
  TurnLeft90         = 21
  Turn180            = 22
  TurnRightOrLeft90  = 23
  TurnRandom         = 24
  TurnTowardPlayer   = 25
  TurnAwayFromPlayer = 26
  SwitchOn           = 27 # 1 param
  SwitchOff          = 28 # 1 param
  ChangeSpeed        = 29 # 1 param
  ChangeFreq         = 30 # 1 param
  WalkAnimeOn        = 31
  WalkAnimeOff       = 32
  StepAnimeOn        = 33
  StepAnimeOff       = 34
  DirectionFixOn     = 35
  DirectionFixOff    = 36
  ThroughOn          = 37
  ThroughOff         = 38
  AlwaysOnTopOn      = 39
  AlwaysOnTopOff     = 40
  Graphic            = 41 # Name, hue, direction, pattern
  Opacity            = 42 # 1 param
  Blending           = 43 # 1 param
  PlaySE             = 44 # 1 param
  Script             = 45 # 1 param
  ScriptAsync        = 101 # 1 param
end

#===============================================================================
# The following is taken from the top of PScreen_Party.
#===============================================================================
class PokemonMail
  attr_accessor :item,:message,:sender,:poke1,:poke2,:poke3

  def initialize(item,message,sender,poke1=nil,poke2=nil,poke3=nil)
    @item=item   # Item represented by this mail
    @message=message   # Message text
    @sender=sender   # Name of the message's sender
    @poke1=poke1   # [species,gender,shininess,form,shadowness,is egg]
    @poke2=poke2
    @poke3=poke3
  end
end

#===============================================================================
# The following is taken from the top of PItem_Items.
#===============================================================================
ITEMID        = 0
ITEMNAME      = 1
ITEMPOCKET    = 2
ITEMPRICE     = 3
ITEMDESC      = 4
ITEMUSE       = 5
ITEMBATTLEUSE = 6
ITEMTYPE      = 7
ITEMMACHINE   = 8

#===============================================================================
# The following is taken from PItem_PokeBalls.
#===============================================================================
def pbBallTypeToBall(balltype)
  if $BallTypes[balltype]
    ret=getID(PBItems,$BallTypes[balltype])
    return ret if ret!=0
  end
  if $BallTypes[0]
    ret=getID(PBItems,$BallTypes[0])
    return ret if ret!=0
  end
  return getID(PBItems,:POKEBALL)
end

$BallTypes={
   0=>:POKEBALL,
   1=>:GREATBALL,
   2=>:SAFARIBALL,
   3=>:ULTRABALL,
   4=>:MASTERBALL,
   5=>:NETBALL,
   6=>:DIVEBALL,
   7=>:NESTBALL,
   8=>:REPEATBALL,
   9=>:TIMERBALL,
   10=>:LUXURYBALL,
   11=>:PREMIERBALL,
   12=>:DUSKBALL,
   13=>:HEALBALL,
   14=>:QUICKBALL,
   15=>:CHERISHBALL,
   16=>:FASTBALL,
   17=>:LEVELBALL,
   18=>:LUREBALL,
   19=>:HEAVYBALL,
   20=>:LOVEBALL,
   21=>:FRIENDBALL,
   22=>:MOONBALL,
   23=>:SPORTBALL
}

#===============================================================================
# The following is taken from PScreen_Options.
#===============================================================================
class PokemonSystem
  attr_accessor :textspeed
  attr_accessor :battlescene
  attr_accessor :battlestyle
  attr_accessor :frame
  attr_accessor :textskin
  attr_accessor :font
  attr_accessor :screensize
  attr_accessor :language

  def language
    return (!@language) ? 0 : @language
  end

  def textskin
    return (!@textskin) ? 0 : @textskin
  end

  def tilemap; return MAPVIEWMODE; end

  def initialize
    @textspeed   = 1   # Text speed (0=slow, 1=mid, 2=fast)
    @battlescene = 0   # Battle scene (animations) (0=on, 1=off)
    @battlestyle = 0   # Battle style (0=shift, 1=set)
    @frame       = 0   # Default window frame (see also $TextFrames)
    @textskin    = 0   # Speech frame
    @font        = 0   # Font (see also $VersionStyles)
    @screensize  = (DEFAULTSCREENZOOM.floor).to_i # 0=half size, 1=full size, 2=double size
    @language    = 0   # Language (see also LANGUAGES in script PokemonSystem)
  end
end