
module PKMNEE::Import

	def self.tilesets
		tilesets = PKMNEE::Util::DataSet.new(PKMN::Map::Tileset)
		incr = 0
		Psych.load_file("#{$rmxp_dir}/export/Data/Tilesets.yaml")["root"].delete_at(0).each do |e|
			tileset = PKMN::Map::Tileset.new
			tileset.id = if e.name == '' # some tilesets have no names...WTF rgss
				incr += 1
				"tileset#{incr}".to_id # give it a default name
			else # it actually has a name
				e.name.to_id
			end
			tileset.name = e.tileset_name
			tileset.image = JavaFX::Image.new("#{$rmxp_dir}/Graphics/Tilesets/#{e.tileset_name}")
			tileset.
		end
		$data[:tilesets] = PKMNEE::Util::DataSet.new(PKMN::Map::Tileset, *(tilesets.values))
	end

	def self.maps
		$maps = {}
		map_files = {}
		map_info = Psych.load_file("#{$rmxp_dir}/export/Data/MapInfos.yaml")["root"]
		(Dir["#{$rmxp_dir}/export/Data/Map*.yaml"].select { |file| file.match(/\d*.yaml$/) }).each do |path|
			path.scan(/Map(\d*).yaml$/) do |num|
				map = PKMN::Map::Base.new
				rmxp = Psych.load_file(path)["root"]
				map.id = map_info[num[0].to_i].name.to_sym
				map.width = rmxp.width
				map.height = rmxp.height
				map.events = rmxp.events
				map.data = rmxp.data
				maps[map.id] = map
			end
		end
		$data[:maps] = PKMNEE::Util::DataSet.new(PKMN::Map::Base, *(maps.values))
	end
end
