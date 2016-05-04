#===============================================================================
#  Overriding Sprite, Viewport, and Plane to support resizing
#  By Peter O.
#  -- This is a stand-alone RGSS script. --
#===============================================================================
$ResizeFactor     = 1.0
$ResizeFactorMul  = 100
$ResizeOffsetX    = 0
$ResizeOffsetY    = 0
$ResizeFactorSet  = false
$HaveResizeBorder = false

def pbSetResizeFactor(factor)
  if $ResizeFactor!=factor
    $ResizeFactor=factor
    $ResizeFactorMul=(factor*100).to_i
    if $ResizeFactorSet!=false
      ObjectSpace.each_object(Sprite){|o|
         next if o.disposed?
         o.x=o.x
         o.y=o.y
         o.ox=o.ox
         o.oy=o.oy
         o.zoom_x=o.zoom_x
         o.zoom_y=o.zoom_y
      }
      ObjectSpace.each_object(Viewport){|o|
         begin
           o.rect=o.rect
           o.ox=o.ox
           o.oy=o.oy
         rescue RGSSError
         end
      }
      ObjectSpace.each_object(Plane){|o|
         next if o.disposed?
         o.zoom_x=o.zoom_x
         o.zoom_y=o.zoom_y
      }
    end
  end
  $ResizeFactorSet=true
  if $HaveResizeBorder
    $ResizeBorder.refresh
  end
  begin
    if Graphics.haveresizescreen
      Graphics.oldresizescreen(
        (Graphics.width+$ResizeOffsetX*2)*factor,
        (Graphics.height+$ResizeOffsetY*2)*factor
      )
    end
    Win32API.SetWindowPos(
       (Graphics.width+$ResizeOffsetX*2)*factor,
       (Graphics.height+$ResizeOffsetY*2)*factor
    )
  rescue
  end
end

def setScreenBorderName(border)
  if !$HaveResizeBorder
    $ResizeBorder=ScreenBorder.new
    $HaveResizeBorder=true
  end
  if $ResizeBorder
    $ResizeBorder.bordername=border
  end
end



module Graphics
  ## Nominal screen size
  @@width=DEFAULTSCREENWIDTH
  @@height=DEFAULTSCREENHEIGHT

  def self.width
    return @@width.to_i
  end

  def self.height
    return @@height.to_i
  end

  @@fadeoutvp=Viewport.new(0,0,640,480)
  @@fadeoutvp.z=0x3FFFFFFF
  @@fadeoutvp.color=Color.new(0,0,0,0)

  def self.brightness
    return (255-@@fadeoutvp.color.alpha)
  end

  def self.brightness=(value)
    value=0 if value<0
    value=255 if value>255
    @@fadeoutvp.color.alpha=255-value
  end

  def self.fadein(frames)
    return if frames<=0
    curvalue=self.brightness
    count=(255-self.brightness)
    frames.times do |i|
      self.brightness=curvalue+(count*i/frames)
      self.update
    end
  end

  def self.wait(frames)
    return if frames<=0
    frames.times do |i|
      self.update
    end
  end

  def self.fadeout(frames)
    return if frames<=0
    curvalue=self.brightness
    count=self.brightness
    frames.times do |i|
      self.brightness=curvalue-(count*i/frames)
      self.update
    end
  end

  class << self
    begin
      x=@@haveresizescreen
    rescue NameError                         # If exception is caught, the class
      if !method_defined?(:oldresizescreen)  # variable wasn't defined yet
        begin
          alias oldresizescreen resize_screen
          @@haveresizescreen=true
        rescue
          @@haveresizescreen=false
        end
      else
        @@haveresizescreen=false
      end
    end

    def haveresizescreen
      @@haveresizescreen
    end
  end

  def self.resize_screen(w,h)
    @@width=w
    @@height=h
    pbSetResizeFactor($ResizeFactor)
  end

  @@deletefailed=false

  def self.snap_to_bitmap
    tempPath=ENV["TEMP"]+"\\tempscreen.bmp"
    if safeExists?(tempPath) && @@deletefailed
      begin
        File.delete(tempPath)
        @@deletefailed=false
      rescue Errno::EACCES
        @@deletefailed=true
        return nil
      end
    end
    if safeExists?("./rubyscreen.dll")
      takescreen=Win32API.new("rubyscreen.dll","TakeScreenshot","p","i")
      takescreen.call(tempPath)
    end
    bm=nil
    if safeExists?(tempPath)
      bm=Bitmap.new(tempPath)
      begin
        File.delete(tempPath)
        @@deletefailed=false
      rescue Errno::EACCES
        @@deletefailed=true
      end
    end
    if bm && bm.get_pixel(0,0).alpha==0
      bm.asOpaque
    end
    if bm && $ResizeOffsetX && $ResizeOffsetY &&
       $ResizeOffsetX!=0 || $ResizeOffsetY!=0
      tmpbitmap=Bitmap.new(Graphics.width*$ResizeFactor,
         Graphics.height*$ResizeFactor)
      tmpbitmap.blt(0,0,bm,Rect.new($ResizeOffsetX*$ResizeFactor,
         $ResizeOffsetY*$ResizeFactor,tmpbitmap.width,tmpbitmap.height))
      bm.dispose
      bm=tmpbitmap
    end
    if bm && (bm.width!=Graphics.width || bm.height!=Graphics.height)
      newbitmap=Bitmap.new(Graphics.width,Graphics.height)
      newbitmap.stretch_blt(newbitmap.rect,bm,Rect.new(0,0,bm.width,bm.height))
      bm.dispose
      bm=newbitmap
    end
    return bm
  end
end



class Sprite
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _x_SpriteResizer x
    alias _y_SpriteResizer y
    alias _ox_SpriteResizer ox
    alias _oy_SpriteResizer oy
    alias _zoomx_SpriteResizer zoom_x
    alias _zoomy_SpriteResizer zoom_y
    alias _xeq_SpriteResizer x=
    alias _yeq_SpriteResizer y=
    alias _zoomxeq_SpriteResizer zoom_x=
    alias _zoomyeq_SpriteResizer zoom_y=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    alias _bushdeptheq_SpriteResizer bush_depth=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(viewport=nil)
    _initialize_SpriteResizer(viewport)
    @resizedX=0
    @resizedY=0
    @resizedOx=0
    @resizedOy=0
    @resizedBushDepth=0
    @resizedZoomX=1.0
    @resizedZoomY=1.0
    if $ResizeOffsetX!=0 && $ResizeOffsetY!=0 && !viewport
      _xeq_SpriteResizer($ResizeOffsetX*$ResizeFactorMul/100)
      _yeq_SpriteResizer($ResizeOffsetY*$ResizeFactorMul/100)
    end
     _zoomxeq_SpriteResizer(@resizedZoomX*$ResizeFactorMul/100)
     _zoomyeq_SpriteResizer(@resizedZoomY*$ResizeFactorMul/100)
   end

  def zoom_x
    return @resizedZoomX
  end

  def zoom_x=(val)
    value=val
    if $ResizeFactorMul!=100
      value=(val.to_f*$ResizeFactorMul/100)
      if (value-0.50).abs<=0.001
        value=0.50
      end
      if (value-1.00).abs<=0.001
        value=1.00
      end
      if (value-1.50).abs<=0.001
        value=1.50
      end
      if (value-2.00).abs<=0.001
        value=2.00
      end
    end
    _zoomxeq_SpriteResizer(value)
    @resizedZoomX=val
  end

  def zoom_y
    return @resizedZoomY
  end

  def zoom_y=(val)
    value=val
    if $ResizeFactorMul!=100
      value=(val.to_f*$ResizeFactorMul/100)
      if (value-0.50).abs<=0.001
        value=0.50
      end
      if (value-1.00).abs<=0.001
        value=1.00
      end
      if (value-1.50).abs<=0.001
        value=1.50
      end
      if (value-2.00).abs<=0.001
        value=2.00
      end
    end
    _zoomyeq_SpriteResizer(value)
    @resizedZoomY=val
  end

  def x
    return @resizedX
  end

  def x=(val)
    if $ResizeFactorMul!=100
      offset=(self.viewport) ? 0 : $ResizeOffsetX
      value=((val.to_i+offset)*$ResizeFactorMul/100)
      _xeq_SpriteResizer(value.to_i)
      @resizedX=val.to_i
    elsif self.viewport
      _xeq_SpriteResizer(val)
      @resizedX=val
    else
      _xeq_SpriteResizer(val + $ResizeOffsetX)
      @resizedX=val
    end
  end

  def y
    return @resizedY
  end

  def bush_depth=(val)
    value=((val.to_i)*$ResizeFactorMul/100)
    _bushdeptheq_SpriteResizer(value.to_i)
    @resizedBushDepth=val.to_i
  end

  def bush_depth
    return @resizedBushDepth
  end

  def y=(val)
    if $ResizeFactorMul!=100
      offset=(self.viewport) ? 0 : $ResizeOffsetY
      value=((val.to_i+offset)*$ResizeFactorMul/100)
      _yeq_SpriteResizer(value.to_i)
      @resizedY=val.to_i
    elsif self.viewport
      _yeq_SpriteResizer(val)
      @resizedY=val
    else
      _yeq_SpriteResizer(val + $ResizeOffsetY)
      @resizedY=val
    end
  end

  def ox=(val)
    if $ResizeFactor!=1.0
      val=(val*$ResizeFactor).to_i
      val=(val/$ResizeFactor).to_i
    end
    @resizedOx=val
    _oxeq_SpriteResizer(val)
  end

  def oy=(val)
    if $ResizeFactor!=1.0
      val=(val*$ResizeFactor).to_i
      val=(val/$ResizeFactor).to_i
    end
    @resizedOy=val
    _oyeq_SpriteResizer(val)
  end

  def ox
    return @resizedOx
  end

  def oy
    return @resizedOy
  end
end



class NotifiableRect < Rect
  def setNotifyProc(proc)
    @notifyProc=proc
  end

  def set(x,y,width,height)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def x=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def y=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def width=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end

  def height=(value)
    super
    @notifyProc.call(self) if @notifyProc
  end
end



class Viewport
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _rect_ViewportResizer rect
    alias _recteq_SpriteResizer rect=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(*arg)
    args=arg.clone
    @oldrect=Rect.new(0,0,100,100)
    _initialize_SpriteResizer(
       @oldrect
    )
    newRect=NotifiableRect.new(0,0,0,0)
    @resizedRectProc=Proc.new {|r|
       if $ResizeFactorMul==100
         @oldrect.set(
            r.x.to_i+$ResizeOffsetX,
            r.y.to_i+$ResizeOffsetY,
            r.width.to_i,
            r.height.to_i
         )
         self._recteq_SpriteResizer(@oldrect)
       else
         @oldrect.set(
            ((r.x+$ResizeOffsetX)*$ResizeFactorMul/100).to_i,
            ((r.y+$ResizeOffsetY)*$ResizeFactorMul/100).to_i,
            (r.width*$ResizeFactorMul/100).to_i,
            (r.height*$ResizeFactorMul/100).to_i
         )
         self._recteq_SpriteResizer(@oldrect)
       end
    }
    newRect.setNotifyProc(@resizedRectProc)
    if arg.length==1
      newRect.set(args[0].x,args[0].y,args[0].width,args[0].height)
    else
      newRect.set(args[0],args[1],args[2],args[3])
    end
    @resizedRect=newRect
    @resizedOx=0
    @resizedOy=0
  end

  def ox
    return @resizedOx
  end

  def ox=(val)
    return if !val
    _oxeq_SpriteResizer((val*$ResizeFactorMul/100).to_i.to_f)
    @resizedOx=val
  end

  def oy
    return @resizedOy
  end

  def oy=(val)
    return if !val
    _oyeq_SpriteResizer((val*$ResizeFactorMul/100).to_i.to_f)
    @resizedOy=val
  end

  def rect
    return @resizedRect
  end

  def rect=(val)
    if val
      newRect=NotifiableRect.new(0,0,100,100)
      newRect.setNotifyProc(@resizedRectProc)
      newRect.set(val.x.to_i,val.y.to_i,val.width.to_i,val.height.to_i)
      @resizedRect=newRect
    end
  end
end



class Plane
  unless @SpriteResizerMethodsAliased
    alias _initialize_SpriteResizer initialize
    alias _zoomxeq_SpriteResizer zoom_x=
    alias _zoomyeq_SpriteResizer zoom_y=
    alias _oxeq_SpriteResizer ox=
    alias _oyeq_SpriteResizer oy=
    @SpriteResizerMethodsAliased=true
  end

  def initialize(viewport=nil)
    _initialize_SpriteResizer(viewport)
    @resizedZoomX=1.0
    @resizedZoomY=1.0
    @resizedOx=0
    @resizedOy=0
    _zoomxeq_SpriteResizer(@resizedZoomX*$ResizeFactorMul/100)
    _zoomyeq_SpriteResizer(@resizedZoomY*$ResizeFactorMul/100)
  end

  def ox
    return @resizedOx
  end

  def ox=(val)
    return if !val
    _oxeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedOx=val
  end

  def oy
    return @resizedOy
  end

  def oy=(val)
    return if !val
    _oyeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedOy=val
  end

  def zoom_x
    return @resizedZoomX
  end

  def zoom_x=(val)
    return if !val
    _zoomxeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedZoomX=val
  end

  def zoom_y
    return @resizedZoomY
  end

  def zoom_y=(val)
    return if !val
    _zoomyeq_SpriteResizer(val*$ResizeFactorMul/100)
    @resizedZoomY=val
  end
end



###################
class ScreenBorder
  def initialize
    initializeInternal
    refresh
  end

  def initializeInternal
    @maximumZ=500000
    @bordername=""
    @sprite=IconSprite.new(0,0) rescue Sprite.new
    @defaultwidth=640
    @defaultheight=480
    @defaultbitmap=Bitmap.new(@defaultwidth,@defaultheight)
  end

  def dispose
    @borderbitmap.dispose if @borderbitmap
    @defaultbitmap.dispose
    @sprite.dispose
  end

  def adjustZ(z)
    if z>=@maximumZ
      @maximumZ=z+1
      @sprite.z=@maximumZ
    end
  end

  def bordername=(value)
    @bordername=value
    refresh
  end

  def refresh
    @sprite.z=@maximumZ
    @sprite.x=-$ResizeOffsetX
    @sprite.y=-$ResizeOffsetY
    @sprite.visible=($ResizeOffsetX>0 && $ResizeOffsetY>0)
    @sprite.bitmap=nil
    if @sprite.visible
      if @bordername!=nil && @bordername!=""
        setSpriteBitmap("Graphics/Pictures/"+@bordername)
      else
        setSpriteBitmap(nil)
        @sprite.bitmap=@defaultbitmap
      end
    end
    @defaultbitmap.clear
    @defaultbitmap.fill_rect(0,0,@defaultwidth,$ResizeOffsetY,Color.new(0,0,0))
    @defaultbitmap.fill_rect(0,0,$ResizeOffsetX,@defaultheight,Color.new(0,0,0))
    @defaultbitmap.fill_rect(@defaultwidth-$ResizeOffsetX,0,
       $ResizeOffsetX,@defaultheight,Color.new(0,0,0))
    @defaultbitmap.fill_rect(0,@defaultheight-$ResizeOffsetY,
       @defaultwidth,$ResizeOffsetY,Color.new(0,0,0))
  end

  private

  def setSpriteBitmap(x)
    if (@sprite.is_a?(IconSprite) rescue false)
      @sprite.setBitmap(x)
    else
      @sprite.bitmap=x ? RPG::Cache.load_bitmap("",x) : nil
    end
  end
end



class Bitmap
  # Fast methods for retrieving bitmap data
  RtlMoveMemory_pi = Win32API.new('kernel32', 'RtlMoveMemory', 'pii', 'i')
  RtlMoveMemory_ip = Win32API.new('kernel32', 'RtlMoveMemory', 'ipi', 'i')
  SwapRgb = Win32API.new('./rubyscreen.dll', 'SwapRgb', 'pi', '') rescue nil

  def setData(x)
    RtlMoveMemory_ip.call(self.address, x, x.length)    
  end

  def getData
    data = "rgba" * width * height
    RtlMoveMemory_pi.call(data, self.address, data.length)
    return data
  end

  def swap32(x)
    return ((x>>24)&0x000000FF)|
           ((x>>8)&0x0000FF00)|
           ((x<<8)&0x00FF0000)|        
           ((x<<24)&0xFF000000)
  end

  def asOpaque
    data=getData
    j=3
    for i in 0...width*height
      data[j]=0xFF
      j+=4
    end
    setData(data)
  end

  def saveToPng(filename)
    bytes=[
       0x89,0x50,0x4E,0x47,0x0D,0x0A,0x1A,0x0A,0x00,0x00,0x00,0x0D
    ].pack("CCCCCCCCCCCC")
    ihdr=[
       0x49,0x48,0x44,0x52,swap32(self.width),swap32(self.height),
       0x08,0x06,0x00,0x00,0x00
    ].pack("CCCCVVCCCCC")
    crc=Zlib::crc32(ihdr)
    ihdr+=[swap32(crc)].pack("V")
    bytesPerScan=self.width*4
    row=(self.height-1)*bytesPerScan
    data=self.getData
    data2=data.clone
    width=self.width
    x=""
    len=bytesPerScan*self.height
    ttt=Time.now
    if SwapRgb
      SwapRgb.call(data2,data2.length)
    else
      # the following is considerably slower
      b=0;c=2;while b!=len
        data2[b]=data[c]
        data2[c]=data[b]
        b+=4;c+=4; 
      end
    end
    #$times.push(Time.now-ttt)
    filter="\0"
    while row>=0
      thisRow=data2[row,bytesPerScan]
      x.concat(filter)
      x.concat(thisRow)
      row-=bytesPerScan
    end
    x=Zlib::Deflate.deflate(x)
    length=x.length
    x="IDAT"+x
    crc=Zlib::crc32(x)
    idat=[swap32(length)].pack("V")
    idat.concat(x)
    idat.concat([swap32(crc)].pack("V"))
    idat.concat([0,0x49,0x45,0x4E,0x44,0xAE,0x42,0x60,0x82].pack("VCCCCCCCC"))
    File.open(filename,"wb"){|f|
       f.write(bytes)
       f.write(ihdr)
       f.write(idat)
    }
  end

  def address
    if !@address
      buffer, ad = "rgba", object_id * 2 + 16
      RtlMoveMemory_pi.call(buffer, ad, 4)
      ad = buffer.unpack("L")[0] + 8
      RtlMoveMemory_pi.call(buffer, ad, 4)
      ad = buffer.unpack("L")[0] + 16
      RtlMoveMemory_pi.call(buffer, ad, 4)
      @address=buffer.unpack("L")[0]
    end
    return @address
  end
end