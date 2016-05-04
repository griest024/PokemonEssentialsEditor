class DebugTerrainTags
  
  # testingzsdgfdsasdfds
  
  
  def initialize
    echo("Terrain tag: ")
    echoln(pbGetTerrainTag)
    echo("Is encounter possible? ")
    echoln($PokemonEncounters.isEncounterPossibleHere?)
    echo("Encounter type: ")
    echoln($PokemonEncounters.pbEncounterType)
    echo("pbIsShallowsTag?(pbGetTerrainTag($game_player)): ")
    echoln(pbIsShallowsTag?(pbGetTerrainTag($game_player)))
    echo("isShallows? ")
    echoln($PokemonEncounters.isShallows?)
    echo("isSand? ")
    echoln($PokemonEncounters.isSand?)
  end
  
end

class DebugWeather

    # class MapMetadata
    #     line_number_start = 0   #the line number of the map id
    #     line_number_end = 0   #the line number  before the next map id
    #     id = nil     
    #     init = false             

    #     def initialize(map_id)
    #         id = map_id
    #         echoln(id)
    #         init = findMap(map_id)
    #         puts init
    #     end

    #     def isMap?(line)
    #         return line == "[" + id + "]"
    #     end

    #     def findMap(map_id)
    #     File.open("PBS/metadata.txt", 'r+') do |f|
    #       echo(f)
    #      f.each_line do |line|
    #         line_number_start++
    #         unless isMap?(line)
    #             echoln(line_number_start + line + "not yet")
    #         else
    #             return true
    #         end
    #      end
    #      return false
    #     end
    # end
######################################################################


id = 0
map_selected = nil


    def initialize
      
    end

    
  def selectMap(map_id)
    map_selected = MapMetadata.new(map_id)
  end
  
  def setWeather(weather_id)
    if map_selected.init
    end
  end
  
    
    def getMetadata(map_id)
      return pbGetMetadata(map_id,MetadataWeather)
    end
    
      
        


end


    