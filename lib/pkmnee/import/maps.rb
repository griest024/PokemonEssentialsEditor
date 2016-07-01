require 'benchmark'
require_relative 'tilesets'

module PKMNEE::Import

	def self.maps(verbose = true)
		ts = tilesets verbose
		puts "\nImporting maps..."
		maps = {}
		map_info = Psych.load_file("#{$rmxp_dir}/export/Data/MapInfos.yaml")["root"]
		(Dir["#{$rmxp_dir}/export/Data/Map*.yaml"].select { |file| file.match(/\d*.yaml$/) }).each.with_index do |path, i|
			path.scan(/Map(\d*).yaml$/) do |id| # get the map idber
				map = PKMN::Map::Map.new
				rmxp = Psych.load_file(path)["root"]
				map.name = map_info[id[0].to_i].name.force_encoding("UTF-8") # extract the name from the map info using the map id we got
				map.id = map.name.force_encoding("UTF-8").to_id
				puts "#{i}:	#{map.id}" if verbose
				map.width = rmxp.width
				map.height = rmxp.height
				map.events = rmxp.events
				map.data = rmxp.data
				map.tileset = ts[rmxp.tileset_id].wrap
				maps[map.id] = map
			end
		end
		folder = "#{$project_dir}/data/map"
		Dir.mkdir(folder) unless File.exists?(folder)
		maps.each do |id, map|
			File.open("#{folder}/#{id}.yaml", "w") { |file| file.write map.to_yaml }
		end
		# $data[:maps] = PKMNEE::Util::DataSet.new(PKMN::Map::Base, *(maps.values))
	end
end
