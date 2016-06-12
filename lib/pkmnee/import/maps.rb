
module PKMNEE::Import

	def self.tilesets
		puts "Importing tilesets..."
		resource_root(:graphics, "#{$rmxp_dir}/Graphics")
		tilesets = {}
		tiles = {}
		incr = 0
		safe_mkdir "#{$project_dir}/res"
		safe_mkdir "#{$project_dir}/res/tiles"
		folder = "#{$project_dir}/data/tileset"
		safe_mkdir folder
		Psych.load_file("#{$rmxp_dir}/export/Data/Tilesets.yaml")["root"].compact.reject { |e| e.name == '' }.each do |e| # load file and skip tilesets with no name
			tileset = PKMN::Map::Tileset.new
			tileset.id = e.name.to_id
			puts "	#{tileset.id}"
			safe_mkdir "#{$project_dir}/res/tiles/#{tileset.id}"
			tileset.name = e.tileset_name
			tileset_image = JavaFX::Image.new("/src/Graphics/Tilesets/#{e.tileset_name}.png")
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
			tyles = []
			reader = tileset_image.getPixelReader
			(tileset_image.getHeight/32).to_i.times do |y|
				8.times do |x|
					id = (y * 8) + x
					tile = PKMN::Map::Tile.new
					tile.id = id
					tile.passage = e.passages[id]
					tile.priority = e.priorities[id]
					tile.terrain_tag = e.terrain_tags[id]
					# tile.image = JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
					tile_path = "#{tileset.id}/#{id}.png"
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::WritableImage.new(reader,x*32,y*32,32,32), nil), "png", Java::File.new("#{$project_dir}/res/tiles/#{tile_path}"))
					tile.image = PKMNEE::Util::TileImageWrapper.new(tile_path)
					tyles << tile
				end
			end
			tileset.image = tileset_image
			tileset.tiles = tyles
			# tiles[tileset.id] = tyles
			# tilesets[tileset.id] = tileset
			File.open("#{folder}/#{tileset.id}.yaml", "w") do |file|
				file.write tileset.to_yaml
			end
		end
		# tilesets.each do |id, ts|
		# 	File.open("#{folder}/#{id}.yaml", "w") do |file|
		# 		file.write ts.to_yaml
		# 	end
		# end
		# folder = "#{$project_dir}/data/tile"
		# Dir.mkdir(folder) unless File.exists?(folder)
		# tiles.each do |id, ary|
		# 	folder = "#{$project_dir}/data/tile/#{id}"
		# 	Dir.mkdir(folder) unless File.exists?(folder)
		# 	ary.each do |tile|
		# 		File.open("#{folder}/#{tile.id}.yaml", "w") { |file| file.write tile.to_yaml }
		# 	end
		# end
		# $tilesets = tilesets
		# $data[:tilesets] = PKMNEE::Util::DataSet.new(PKMN::Map::Tileset, *(tilesets.values))
	end

	def self.maps
		tilesets
		puts "Importing maps..."
		maps = {}
		map_info = Psych.load_file("#{$rmxp_dir}/export/Data/MapInfos.yaml")["root"]
		(Dir["#{$rmxp_dir}/export/Data/Map*.yaml"].select { |file| file.match(/\d*.yaml$/) }).each do |path|
			path.scan(/Map(\d*).yaml$/) do |id| # get the map idber
				map = PKMN::Map::Map.new
				rmxp = Psych.load_file(path)["root"]
				map.id = map_info[id[0].to_i].name.to_id # extract the id from the map info using the map id we got
				puts "	#{map.id}"
				map.width = rmxp.width
				map.height = rmxp.height
				map.events = rmxp.events
				map.data = rmxp.data
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
