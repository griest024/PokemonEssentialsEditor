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
