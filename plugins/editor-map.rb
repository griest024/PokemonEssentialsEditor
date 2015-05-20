

class MapEditor

	include JRubyFX::Controller

	EDITOR_NAME = "Map Editor"

	def initialize
		load_map("082")
		create_gui
	end

	def load_map(mapID)
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/Map" + mapID + ".yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@map = parsed["root"]
	end

	def create_gui
		
	end



	def pack_table(mapTable)
		mapData = mapTable.data
		mapData.each_index do |i|
			ele = mapData[i]
			a = ele % 8
			b = ele / 8
			x = i % mapTable.xsize
			y = i / mapTable.xsize
		end
	end

	def self.editor_name
		EDITOR_NAME
	end



end


declare_plugin("Map Editor", MapEditor)