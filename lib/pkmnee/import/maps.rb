
module PKMNEE::Import

	def self.maps
		maps = PKMNEE::Util::DataSet.new(PKMN::Map::Base)
		map_files = {}
		map_info = Psych.load_file("#{$rmxp_dir}/export/Data/MapInfos.yaml")["root"]
		(Dir["#{$rmxp_dir}/export/Data/Map*.yaml"].select { |file| file.match(/\d*.yaml$/) }).each do |path|
			path.scan(/Map(\d*).yaml$/) do |n|
				map = PKMN::Map::Base.new
				rmxp = Psych.load_file(path)["root"]
				map.id = map_info[n[0].to_i].name.to_sym
				map.width = rmxp.width
				map.height = rmxp.height
				map.events = rmxp.events
				map.data = rmxp.data
				maps.addData(map)
			end
		end
		$data[:maps] = maps
	end
end
