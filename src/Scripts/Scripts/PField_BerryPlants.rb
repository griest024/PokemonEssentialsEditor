Events.onSpritesetCreate+=proc{|sender,e|
   spriteset=e[0]
   viewport=e[1]
   map=spriteset.map
   for i in map.events.keys
     if map.events[i].name=="BerryPlant"
       spriteset.addUserSprite(BerryPlantMoistureSprite.new(map.events[i],map,viewport))
       spriteset.addUserSprite(BerryPlantSprite.new(map.events[i],map,viewport))
     end
   end
}



class BerryPlantMoistureSprite
  def initialize(event,map,viewport=nil)
    @event=event
    @map=map
    @light = IconSprite.new(0,0,viewport)
    updateGraphic
    @disposed=false
  end

  def disposed?
    return @disposed
  end

  def dispose
    @light.dispose
    @map=nil
    @event=nil
    @disposed=true
  end

  def updateGraphic
    if @event.variable && @event.variable.length>6
      if @event.variable[1]<=0
        @light.setBitmap("")
      elsif @event.variable[4]>50
        @light.setBitmap("Graphics/Characters/berrytreeWet")
      elsif @event.variable[4]>0
        @light.setBitmap("Graphics/Characters/berrytreeDamp")
      else
        @light.setBitmap("Graphics/Characters/berrytreeDry")
      end
    else
      @light.setBitmap("")
    end
  end

  def update
    return if !@light || !@event
    @light.update
    updateGraphic
    @light.ox=16
    @light.oy=24
    if (Object.const_defined?(:ScreenPosHelper) rescue false)
      @light.x = ScreenPosHelper.pbScreenX(@event)
      @light.y = ScreenPosHelper.pbScreenY(@event)
      @light.zoom_x = ScreenPosHelper.pbScreenZoomX(@event)
    else
      @light.x = @event.screen_x
      @light.y = @event.screen_y
      @light.zoom_x = 1.0
    end
    @light.zoom_y = @light.zoom_x
    pbDayNightTint(@light)
  end
end



class BerryPlantSprite
  # Berry, hours per stage, drying per hour, min yield, max yield, plural
  BERRYVALUES=[[:CHERIBERRY,  3,15, 2,5,  _INTL("Cheri Berries")],
               [:CHESTOBERRY, 3,15, 2,5,  _INTL("Chesto Berries")],
               [:PECHABERRY,  3,15, 2,5,  _INTL("Pecha Berries")],
               [:RAWSTBERRY,  3,15, 2,5,  _INTL("Rawst Berries")],
               [:ASPEARBERRY, 3,15, 2,5,  _INTL("Aspear Berries")],
               [:LEPPABERRY,  4,15, 2,5,  _INTL("Leppa Berries")],
               [:ORANBERRY,   4,15, 2,5,  _INTL("Oran Berries")],
               [:PERSIMBERRY, 4,15, 2,5,  _INTL("Persim Berries")],
               [:LUMBERRY,    12,8, 2,5,  _INTL("Lum Berries")],
               [:SITRUSBERRY, 8,7,  2,5,  _INTL("Sitrus Berries")],
               [:FIGYBERRY,   5,10, 1,5,  _INTL("Figy Berries")],
               [:WIKIBERRY,   5,10, 1,5,  _INTL("Wiki Berries")],
               [:MAGOBERRY,   5,10, 1,5,  _INTL("Mago Berries")],
               [:AGUAVBERRY,  5,10, 1,5,  _INTL("Aguav Berries")],
               [:IAPAPABERRY, 5,10, 1,5,  _INTL("Iapapa Berries")],
               [:RAZZBERRY,   2,35, 2,10, _INTL("Razz Berries")],
               [:BLUKBERRY,   2,35, 2,10, _INTL("Bluk Berries")],
               [:NANABBERRY,  2,35, 2,10, _INTL("Nanab Berries")],
               [:WEPEARBERRY, 2,35, 2,10, _INTL("Wepear Berries")],
               [:PINAPBERRY,  2,35, 2,10, _INTL("Pinap Berries")],
               [:POMEGBERRY,  8,8,  1,5,  _INTL("Pomeg Berries")],
               [:KELPSYBERRY, 8,8,  1,5,  _INTL("Kelpsy Berries")],
               [:QUALOTBERRY, 8,8,  1,5,  _INTL("Qualot Berries")],
               [:HONDEWBERRY, 8,8,  1,5,  _INTL("Hondew Berries")],
               [:GREPABERRY,  8,8,  1,5,  _INTL("Grepa Berries")],
               [:TAMATOBERRY, 8,8,  1,5,  _INTL("Tamato Berries")],
               [:CORNNBERRY,  6,10, 2,10, _INTL("Cornn Berries")],
               [:MAGOSTBERRY, 6,10, 2,10, _INTL("Magost Berries")],
               [:RABUTABERRY, 6,10, 2,10, _INTL("Rabuta Berries")],
               [:NOMELBERRY,  6,10, 2,10, _INTL("Nomel Berries")],
               [:SPELONBERRY, 15,8, 2,15, _INTL("Spelon Berries")],
               [:PAMTREBERRY, 15,8, 3,15, _INTL("Pamtre Berries")],
               [:WATMELBERRY, 15,8, 2,15, _INTL("Watmel Berries")],
               [:DURINBERRY,  15,8, 3,15, _INTL("Durin Berries")],
               [:BELUEBERRY,  15,8, 2,15, _INTL("Belue Berries")],
               [:OCCABERRY,   18,6, 1,5,  _INTL("Occa Berries")],
               [:PASSHOBERRY, 18,6, 1,5,  _INTL("Passho Berries")],
               [:WACANBERRY,  18,6, 1,5,  _INTL("Wacan Berries")],
               [:RINDOBERRY,  18,6, 1,5,  _INTL("Rindo Berries")],
               [:YACHEBERRY,  18,6, 1,5,  _INTL("Yache Berries")],
               [:CHOPLEBERRY, 18,6, 1,5,  _INTL("Chople Berries")],
               [:KEBIABERRY,  18,6, 1,5,  _INTL("Kebia Berries")],
               [:SHUCABERRY,  18,6, 1,5,  _INTL("Shuca Berries")],
               [:COBABERRY,   18,6, 1,5,  _INTL("Coba Berries")],
               [:PAYAPABERRY, 18,6, 1,5,  _INTL("Payapa Berries")],
               [:TANGABERRY,  18,6, 1,5,  _INTL("Tanga Berries")],
               [:CHARTIBERRY, 18,6, 1,5,  _INTL("Charti Berries")],
               [:KASIBBERRY,  18,6, 1,5,  _INTL("Kasib Berries")],
               [:HABANBERRY,  18,6, 1,5,  _INTL("Haban Berries")],
               [:COLBURBERRY, 18,6, 1,5,  _INTL("Colbur Berries")],
               [:BABIRIBERRY, 18,6, 1,5,  _INTL("Babiri Berries")],
               [:CHILANBERRY, 18,6, 1,5,  _INTL("Chilan  Berries")],
               [:LIECHIBERRY, 24,4, 1,5,  _INTL("Liechi Berries")],
               [:GANLONBERRY, 24,4, 1,5,  _INTL("Ganlon Berries")],
               [:SALACBERRY,  24,4, 1,5,  _INTL("Salac Berries")],
               [:PETAYABERRY, 24,4, 1,5,  _INTL("Petaya Berries")],
               [:APICOTBERRY, 24,4, 1,5,  _INTL("Apicot Berries")],
               [:LANSATBERRY, 24,4, 1,5,  _INTL("Lansat Berries")],
               [:STARFBERRY,  24,4, 1,5,  _INTL("Starf Berries")],
               [:ENIGMABERRY, 24,7, 1,5,  _INTL("Enigma Berries")],
               [:MICLEBERRY,  24,7, 1,5,  _INTL("Micle Berries")],
               [:CUSTAPBERRY, 24,7, 1,5,  _INTL("Custap Berries")],
               [:JACOBABERRY, 24,7, 1,5,  _INTL("Jacoba Berries")],
               [:ROWAPBERRY,  24,7, 1,5,  _INTL("Rowap Berries")]]
  REPLANTS=9

  def initialize(event,map,viewport)
    @event=event
    @map=map
    @oldstage=0
    @disposed=false
    berryData=event.variable
    return if !berryData
    @oldstage=berryData[0]
    @event.character_name=""
    berryData=updatePlantDetails(berryData)
    setGraphic(berryData,true)     # Set the event's graphic
    event.setVariable(berryData)   # Set new berry data
  end

  def dispose
    @event=nil
    @map=nil
    @disposed=true
  end

  def disposed?
    @disposed
  end

  def update                      # Constantly updates, used only to immediately
    berryData=@event.variable     # change sprite when planting/picking berries
    if berryData
      berryData=updatePlantDetails(berryData) if berryData.length>6
      setGraphic(berryData)
    end
  end

  def updatePlantDetails(berryData)
    berryvalues=nil
    for i in BERRYVALUES
      if isConst?(berryData[1],PBItems,i[0])
        berryvalues=i
        break
      end
    end
    berryvalues=BERRYVALUES[0] if !berryvalues
    timeperstage=berryvalues[1]
    if berryData.length>6
      # Gen 4 growth mechanisms
      if berryData[0]>0
        dryingrate=berryvalues[2]
        timeperstage*=3600
        if hasConst?(PBItems,:GROWTHMULCH) && isConst?(berryData[7],PBItems,:GROWTHMULCH)
          timeperstage=(timeperstage*0.75).to_i
          dryingrate=(dryingrate*1.5).ceil
        elsif hasConst?(PBItems,:DAMPMULCH) && isConst?(berryData[7],PBItems,:DAMPMULCH)
          timeperstage=(timeperstage*1.25).to_i
          dryingrate=(dryingrate/2).floor
        end
        # Get time elapsed since last check
        timenow=pbGetTimeNow
        timeDiff=(timenow.to_i-berryData[3]) # in seconds
        return berryData if timeDiff<=0
        berryData[3]=timenow.to_i # last updated now
        hasreplanted=true
        while hasreplanted
          hasreplanted=false
          secondsalive=berryData[2]
          # Should replant itself?
          growinglife=(berryData[5]>0) ? 3 : 4 # number of growing stages
          numlifestages=growinglife+4 # number of growing + ripe stages
          numlifestages+=2 if hasConst?(PBItems,:STABLEMULCH) &&
                               isConst?(berryData[7],PBItems,:STABLEMULCH)
          if secondsalive+timeDiff>=timeperstage*numlifestages
            # Should replant
            # Has it been replanted too many times already?
            replantmult=1
            replantmult=1.5 if hasConst?(PBItems,:GOOEYMULCH) &&
                               isConst?(berryData[7],PBItems,:GOOEYMULCH)
            if berryData[5]>=(REPLANTS*replantmult).ceil   # Too many replants
              berryData=nil
              break
            end
            # Replant
            berryData[0]=2   # replants start in sprouting stage
            berryData[2]=0   # seconds alive
            berryData[5]+=1  # add to replant count
            berryData[6]=0   # yield penalty
            timeDiff-=(timeperstage*numlifestages-secondsalive)
            hasreplanted=true
          else
            # Reduce dampness, apply yield penalty if dry
            oldhourtick=(secondsalive/3600).floor
            newhourtick=(([secondsalive+timeDiff,timeperstage*growinglife].min)/3600).floor
            (newhourtick-oldhourtick).times do
              if berryData[4]>0
                berryData[4]=[berryData[4]-dryingrate,0].max
              else
                berryData[6]+=1
              end
            end
            # Advance growth stage
            if secondsalive+timeDiff>=timeperstage*growinglife
              berryData[0]=5
            else
              berryData[0]=1+((secondsalive+timeDiff)/timeperstage).floor
              berryData[0]+=1 if berryData[0]<5 && berryData[5]>0 # replants start at stage 2
            end
            # Update the "seconds alive" counter
            berryData[2]+=timeDiff
            break
          end
        end
      end
    else
      # Gen 3 growth mechanics
      loop do
        break if berryData[0]==0
        levels=0
        if berryData[0]>0 && berryData[0]<5
          # Advance time
          timenow=pbGetTimeNow
          timeDiff=(timenow.to_i-berryData[3]) # in seconds
          if timeDiff>=timeperstage*3600
           levels+=1
          end
          if timeDiff>=timeperstage*2*3600
            levels+=1
          end
          if timeDiff>=timeperstage*3*3600
            levels+=1
          end
          if timeDiff>=timeperstage*4*3600
            levels+=1
          end
          levels=5-berryData[0] if levels>5-berryData[0]
          break if levels==0
          berryData[2]=false
          berryData[3]+=levels*timeperstage*3600
          berryData[0]+=levels
          berryData[0]=5 if berryData[0]>5
        end
        if berryData[0]>=5
          # Advance time
          timenow=pbGetTimeNow
          timeDiff=(timenow.to_i-berryData[3]) # in seconds
          if timeDiff>=timeperstage*3600*4 # ripe for 4 times as long as a stage
            # Replant
            berryData[0]=2 # restarts in sprouting stage
            berryData[2]=false
            berryData[3]+=timeperstage*4*3600
            berryData[4]=0
            berryData[5]+=1                     # add to replanted count
            if berryData[5]>REPLANTS            # Too many replants
              berryData=[0,0,false,0,0,0]
              break
            end
          else
            break
          end
        end
      end
      if berryData[0]>0 && berryData[0]<5
        # Reset watering
        if $game_screen && 
           ($game_screen.weather_type==1 || $game_screen.weather_type==2)
          # If raining, plant is already watered
          if berryData[2]==false
            berryData[2]=true
            berryData[4]+=1
          end
        end
      end
    end
    return berryData
  end

  def setGraphic(berryData,fullcheck=false)
    return if !berryData
    if berryData[0]==0
      @event.character_name=""
    elsif berryData[0]==1                     # X planted
      @event.character_name="berrytreeplanted"   # Common to all berries
      @event.turn_down
    elsif fullcheck || berryData.length>6
      filename=sprintf("berrytree%s",getConstantName(PBItems,berryData[1])) rescue nil
      filename=sprintf("berrytree%03d",berryData[1]) if !pbResolveBitmap("Graphics/Characters/"+filename)
      if pbResolveBitmap("Graphics/Characters/"+filename)
        @event.character_name=filename
        @event.turn_down if berryData[0]==2   # X sprouted
        @event.turn_left if berryData[0]==3   # X taller
        @event.turn_right if berryData[0]==4  # X flowering
        @event.turn_up if berryData[0]==5     # X berries
      else
        @event.character_name="Object ball"
      end
      if @oldstage!=berryData[0] && berryData.length>6
        $scene.spriteset.addUserAnimation(PLANT_SPARKLE_ANIMATION_ID,@event.x,@event.y) if $scene.spriteset
        @oldstage=berryData[0]
      end
    end
  end
end



def pbBerryPlant
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  if !berryData
    if NEWBERRYPLANTS
      berryData=[0,0,0,0,0,0,0,0]
    else
      berryData=[0,0,false,0,0,0]
    end
  end
  # Stop the event turning towards the player
  case berryData[0]
  when 1  # X planted
    thisEvent.turn_down
  when 2  # X sprouted
    thisEvent.turn_down
  when 3  # X taller
    thisEvent.turn_left
  when 4  # X flowering
    thisEvent.turn_right
  when 5  # X berries
    thisEvent.turn_up
  end
  berryvalues=nil
  for i in BerryPlantSprite::BERRYVALUES
    if isConst?(berryData[1],PBItems,i[0])
      berryvalues=i
      break
    end
  end
  berryvalues=BerryPlantSprite::BERRYVALUES[0] if !berryvalues
  watering=[]
  watering.push(getConst(PBItems,:SPRAYDUCK)) if hasConst?(PBItems,:SPRAYDUCK)
  watering.push(getConst(PBItems,:SQUIRTBOTTLE)) if hasConst?(PBItems,:SQUIRTBOTTLE)
  watering.push(getConst(PBItems,:WAILMERPAIL)) if hasConst?(PBItems,:WAILMERPAIL)
  berry=berryData[1]
  case berryData[0]
  when 0  # empty
    if NEWBERRYPLANTS
      # Gen 4 planting mechanics
      if !berryData[7] || berryData[7]==0 # No mulch used yet
        cmd=Kernel.pbMessage(_INTL("It's soft, earthy soil."),[
                            _INTL("Fertilize"),
                            _INTL("Plant Berry"),
                            _INTL("Exit")],-1)
        if cmd==0 # Fertilize
          ret=0
          pbFadeOutIn(99999){
             scene=PokemonBag_Scene.new
             screen=PokemonBagScreen.new(scene,$PokemonBag)
             ret=screen.pbChooseItemScreen
          }
          if ret>0
            berryData[7]=ret if pbIsMulch?(ret)
            Kernel.pbMessage(_INTL("The {1} was scattered on the soil.",PBItems.getName(ret)))
            if Kernel.pbConfirmMessage(_INTL("Want to plant a Berry?"))
              pbFadeOutIn(99999){
                 scene=PokemonBag_Scene.new
                 screen=PokemonBagScreen.new(scene,$PokemonBag)
                 berry=screen.pbChooseBerryScreen
              }
              if berry>0
                timenow=pbGetTimeNow
                berryData[0]=1             # growth stage (1-5)
                berryData[1]=berry         # item ID of planted berry
                berryData[2]=0             # seconds alive
                berryData[3]=timenow.to_i  # time of last checkup (now)
                berryData[4]=100           # dampness value
                berryData[5]=0             # number of replants
                berryData[6]=0             # yield penalty
                $PokemonBag.pbDeleteItem(berry,1)
                Kernel.pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
                   PBItems.getName(berry)))
              end
            end
            interp.setVariable(berryData)
            return
          end
        elsif cmd==1 # Plant Berry
          pbFadeOutIn(99999){
             scene=PokemonBag_Scene.new
             screen=PokemonBagScreen.new(scene,$PokemonBag)
             berry=screen.pbChooseBerryScreen
          }
          if berry>0
            timenow=pbGetTimeNow
            berryData[0]=1             # growth stage (1-5)
            berryData[1]=berry         # item ID of planted berry
            berryData[2]=0             # seconds alive
            berryData[3]=timenow.to_i  # time of last checkup (now)
            berryData[4]=100           # dampness value
            berryData[5]=0             # number of replants
            berryData[6]=0             # yield penalty
            $PokemonBag.pbDeleteItem(berry,1)
            Kernel.pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
               PBItems.getName(berry)))
            interp.setVariable(berryData)
          end
          return
        end
      else
        Kernel.pbMessage(_INTL("{1} has been laid down.",PBItems.getName(berryData[7])))
        if Kernel.pbConfirmMessage(_INTL("Want to plant a Berry?"))
          pbFadeOutIn(99999){
             scene=PokemonBag_Scene.new
             screen=PokemonBagScreen.new(scene,$PokemonBag)
             berry=screen.pbChooseBerryScreen
          }
          if berry>0
            timenow=pbGetTimeNow
            berryData[0]=1             # growth stage (1-5)
            berryData[1]=berry         # item ID of planted berry
            berryData[2]=0             # seconds alive
            berryData[3]=timenow.to_i  # time of last checkup (now)
            berryData[4]=100           # dampness value
            berryData[5]=0             # number of replants
            berryData[6]=0             # yield penalty
            $PokemonBag.pbDeleteItem(berry,1)
            Kernel.pbMessage(_INTL("The {1} was planted in the soft, earthy soil.",
               PBItems.getName(berry)))
            interp.setVariable(berryData)
          end
          return
        end
      end
    else
      # Gen 3 planting mechanics
      if Kernel.pbConfirmMessage(_INTL("It's soft, loamy soil.\nPlant a berry?"))
        pbFadeOutIn(99999){
           scene=PokemonBag_Scene.new
           screen=PokemonBagScreen.new(scene,$PokemonBag)
           berry=screen.pbChooseBerryScreen
        }
        if berry>0
          timenow=pbGetTimeNow
          berryData[0]=1             # growth stage (1-5)
          berryData[1]=berry         # item ID of planted berry
          berryData[2]=false         # watered in this stage?
          berryData[3]=timenow.to_i  # time planted
          berryData[4]=0             # total waterings
          berryData[5]=0             # number of replants
          berryData[6]=nil; berryData[7]=nil; berryData.compact! # for compatibility
          $PokemonBag.pbDeleteItem(berry,1)
          Kernel.pbMessage(_INTL("{1} planted a {2} in the soft loamy soil.",
             $Trainer.name,PBItems.getName(berry)))
          interp.setVariable(berryData)
        end
        return
      end
    end
  when 1 # X planted
    Kernel.pbMessage(_INTL("A {1} was planted here.",PBItems.getName(berry)))
  when 2  # X sprouted
    Kernel.pbMessage(_INTL("The {1} has sprouted.",PBItems.getName(berry)))
  when 3  # X taller
    Kernel.pbMessage(_INTL("The {1} plant is growing bigger.",PBItems.getName(berry)))
  when 4  # X flowering
    if NEWBERRYPLANTS
      Kernel.pbMessage(_INTL("This {1} plant is in bloom!",PBItems.getName(berry)))
    else
      case berryData[4]
      when 4
        Kernel.pbMessage(_INTL("This {1} plant is in fabulous bloom!",PBItems.getName(berry)))
      when 3
        Kernel.pbMessage(_INTL("This {1} plant is blooming very beautifully!",PBItems.getName(berry)))
      when 2
        Kernel.pbMessage(_INTL("This {1} plant is blooming prettily!",PBItems.getName(berry)))
      when 1
        Kernel.pbMessage(_INTL("This {1} plant is blooming cutely!",PBItems.getName(berry)))
      else
        Kernel.pbMessage(_INTL("This {1} plant is in bloom!",PBItems.getName(berry)))
      end
    end
  when 5  # X berries
    # Get berry yield (berrycount)
    berrycount=1
    if berryData.length>6
      # Gen 4 berry yield calculation
      berrycount=[berryvalues[4]-berryData[6],berryvalues[3]].max
    else
      # Gen 3 berry yield calculation
      if berryData[4]>0
        randomno=rand(1+berryvalues[4]-berryvalues[3])
        berrycount=(((berryvalues[4]-berryvalues[3])*(berryData[4]-1)+randomno)/4).floor+berryvalues[3]
      else
        berrycount=berryvalues[3]
      end
    end
    plural=(berryvalues[5]) ? berryvalues[5] : PBItems.getName(item)
    if berrycount>1
      message=_INTL("There are {1} {2}!\nWant to pick them?",berrycount,plural)
    else
      message=_INTL("There is 1 {1}!\nWant to pick it?",PBItems.getName(berry))
    end
    if Kernel.pbConfirmMessage(message)
      if !$PokemonBag.pbCanStore?(berryData[1],berrycount)
        Kernel.pbMessage(_INTL("Too bad...\nThe bag is full."))
        return
      end
      $PokemonBag.pbStoreItem(berryData[1],berrycount)
      if berrycount>1
        Kernel.pbMessage(_INTL("You picked the {1} {2}.\\wtnp[30]",berrycount,plural))
        Kernel.pbMessage(_INTL("{1} put away the {2} in the <icon=bagPocket#{BERRYPOCKET}>\\c[1]Berries\\c[0] Pocket.\1",
           $Trainer.name,plural))
      else
        Kernel.pbMessage(_INTL("You picked the {1}.\\wtnp[30]",PBItems.getName(berry)))
        Kernel.pbMessage(_INTL("{1} put away the {2} in the <icon=bagPocket#{BERRYPOCKET}>\\c[1]Berries\\c[0] Pocket.\1",
           $Trainer.name,PBItems.getName(berry)))
      end
      if NEWBERRYPLANTS
        Kernel.pbMessage(_INTL("The soil returned to its soft and earthy state.\1"))
        berryData=[0,0,0,0,0,0,0,0]
      else
        Kernel.pbMessage(_INTL("The soil returned to its soft and loamy state.\1"))
        berryData=[0,0,false,0,0,0]
      end
      interp.setVariable(berryData)
    end
  end
  case berryData[0]
  when 1, 2, 3, 4
    for i in watering
      if i!=0 && $PokemonBag.pbQuantity(i)>0
        if Kernel.pbConfirmMessage(_INTL("Want to sprinkle some water with the {1}?",PBItems.getName(i)))
          if berryData.length>6
            # Gen 4 berry watering mechanics
            berryData[4]=100
          else
            # Gen 3 berry watering mechanics
            if berryData[2]==false
              berryData[4]+=1
              berryData[2]=true
            end
          end
          interp.setVariable(berryData)
          Kernel.pbMessage(_INTL("{1} watered the plant.\\wtnp[40]",$Trainer.name))
          if NEWBERRYPLANTS
            Kernel.pbMessage(_INTL("There! All happy!"))
          else
            Kernel.pbMessage(_INTL("The plant seemed to be delighted."))
          end
        end
        break
      end
    end
  end
end

def pbPickBerry(berry,qty=1)
  interp=pbMapInterpreter
  thisEvent=interp.get_character(0)
  berryData=interp.getVariable
  berryplural=_INTL("unknown berries")
  if berry.is_a?(String) || berry.is_a?(Symbol)
    berry=getID(PBItems,berry)
  end
  for i in BerryPlantSprite::BERRYVALUES
    if isConst?(berry,PBItems,i[0])
      berryplural=i[5]
      break
    end
  end
  if qty>1
    message=_INTL("There are {1} {2}!\nWant to pick them?",qty,berryplural)
  else
    message=_INTL("There is 1 {1}!\nWant to pick it?",PBItems.getName(berry))
  end
  if Kernel.pbConfirmMessage(message)
    if !$PokemonBag.pbCanStore?(berry,qty)
      Kernel.pbMessage(_INTL("Too bad...\nThe bag is full."))
      return
    end
    $PokemonBag.pbStoreItem(berry,qty)
    pocket=pbGetPocket(berry)
    if qty>1
      Kernel.pbMessage(_INTL("You picked the {1} {2}.\\wtnp[30]",qty,berryplural))
      Kernel.pbMessage(_INTL("{1} put away the {2} in the <icon=bagPocket#{pocket}>\\c[1]Berries\\c[0] Pocket.\1",
         $Trainer.name,berryplural))
    else
      Kernel.pbMessage(_INTL("You picked the {1}.\\wtnp[30]",PBItems.getName(berry)))
      Kernel.pbMessage(_INTL("{1} put away the {2} in the <icon=bagPocket#{pocket}>\\c[1]Berries\\c[0] Pocket.\1",
         $Trainer.name,PBItems.getName(berry)))
    end
    if NEWBERRYPLANTS
      Kernel.pbMessage(_INTL("The soil returned to its soft and earthy state.\1"))
      berryData=[0,0,0,0,0,0,0,0]
    else
      Kernel.pbMessage(_INTL("The soil returned to its soft and loamy state.\1"))
      berryData=[0,0,false,0,0,0]
    end
    interp.setVariable(berryData)
    pbSetSelfSwitch(thisEvent.id,"A",true)
  end
end