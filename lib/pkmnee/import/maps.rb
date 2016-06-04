
module PKMNEE::Import

	def self.tilesets
		puts "Importing tilesets..."
		resource_root(:graphics, "#{$rmxp_dir}/Graphics")
		tilesets = {}
		incr = 0
		Psych.load_file("#{$rmxp_dir}/export/Data/Tilesets.yaml")["root"].compact.each do |e|
			tileset = PKMN::Map::Tileset.new
			tileset.id = if e.name == '' # some tilesets have no names...WTF rgss
				incr += 1
				"tileset#{incr}".to_id # give it a default name
			else # it actually has a name
				e.name.to_id
			end
			tileset.name = e.tileset_name
			tileset_image = JavaFX::Image.new(resource_url(:graphics, "Tilesets/#{tileset.name}.png").to_s)
			# autotiles
			# autotiles = []
			# autotile_names = e.autotile_names
			# autotile_names.unshift("").map! { |s| s == "" ? "autotile_blank" : s }
			# (autotile_names.map { |name| JavaFX::Image.new("#{$rmxp_dir}/Graphics/Autotiles/#{name}.png") }).each do |img|
			# 	autotile = []
			# 	reader = img.getPixelReader
			# 	if img.getHeight == 128
			# 		8.times do |y|
			# 			6.times do |x|
			# 				img = JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
			# 				autotile << img
			# 			end
			# 		end
			# 		$autotile_def.each do |a|
			# 			tile = JavaFX::WritableImage.new(32, 32)
			# 			writer = tile.getPixelWriter
			# 			writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
			# 			writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
			# 			writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
			# 			writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
			# 			autotiles << tile
			# 		end
			# 	else
			# 		48.times {autotiles << JavaFX::WritableImage.new(reader, 0, 0, 32, 32)}
			# 	end
			# end
			# tileset.autotile_names = autotile_names
			# tileset.autotiles = autotiles
			# normal tiles
			images = []
			reader = tileset_image.getPixelReader
			(tileset_image.getHeight/32).to_i.times do |y|
				8.times do |x|
					images << JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
			tileset.image = tileset_image
			tileset.images = images
			tilesets[tileset.id] = tileset
		end
		folder = "#{$project_dir}/data/tilesets"
		Dir.mkdir(folder) unless File.exists?(folder)
		tilesets.each do |id, ts|
			File.open("#{folder}/#{id}.yaml", "w") { |file| file.write ts.to_yaml }
		end
		# $data[:tilesets] = PKMNEE::Util::DataSet.new(PKMN::Map::Tileset, *(tilesets.values))
	end

	def self.maps
		tilesets
		puts "Importing maps..."
		maps = {}
		map_info = Psych.load_file("#{$rmxp_dir}/export/Data/MapInfos.yaml")["root"]
		(Dir["#{$rmxp_dir}/export/Data/Map*.yaml"].select { |file| file.match(/\d*.yaml$/) }).each do |path|
			path.scan(/Map(\d*).yaml$/) do |num| # get the map number
				map = PKMN::Map::Base.new
				rmxp = Psych.load_file(path)["root"]
				map.id = map_info[num[0].to_i].name.to_id # extract the id from the map info using the map num we got
				map.width = rmxp.width
				map.height = rmxp.height
				map.events = rmxp.events
				map.data = rmxp.data
				maps[map.id] = map
			end
		end
		folder = "#{$project_dir}/data/maps"
		Dir.mkdir(folder) unless File.exists?(folder)
		maps.each do |id, map|
			File.open("#{folder}/#{id}.yaml", "w") { |file| file.write map.to_yaml }
		end
		# $data[:maps] = PKMNEE::Util::DataSet.new(PKMN::Map::Base, *(maps.values))
	end
end
