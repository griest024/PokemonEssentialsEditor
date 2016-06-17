require 'benchmark'

module PKMNEE::Import

	def self.autotiles
		puts "Importing autotiles..."
		autotiles = {}
		safe_mkdir "#{$project_dir}/res/autotile", "#{$project_dir}/data/autotile", "#{$project_dir}/res/autotile/blank"
		JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::Image.new(resource_url(:images, "autotile_blank.png").to_s), nil), "png", Java::File.new("#{$rmxp_dir}/Graphics/Autotiles/Blank.png"))
		Dir["#{$rmxp_dir}/Graphics/Autotiles/*"].each do |file|
			tiles = []
			autotile = []
			id = (name = File.basename(file, ".*")).to_id
			puts "	#{id}"
			safe_mkdir "#{$project_dir}/res/autotile/#{id}", "#{$project_dir}/data/autotile/#{id}"
			img = JavaFX::Image.new(resource_url(:graphics, "Autotiles/#{name}.png").to_s)
			reader = img.getPixelReader
			if img.getHeight == 128
				8.times do |y|
					6.times do |x|
						autotile << JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
					end
				end
				$autotile_def.each.with_index do |a, i|
					auto_image = JavaFX::WritableImage.new(32, 32)
					writer = auto_image.getPixelWriter
					writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
					writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
					writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
					writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
					image_path = "#{id}/#{i}.png"
					# tile = PKMN::Map::Tile.new
					# tile.id = name
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(auto_image, nil), "png", Java::File.new("#{$project_dir}/res/autotile/#{image_path}"))
					tiles << PKMNEE::Util::AutotileImageWrapper.new(image_path)
				end
			else
				48.times do |n|
					image_path = "#{id}/#{n}.png"
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::WritableImage.new(reader, 0, 0, 32, 32), nil), "png", Java::File.new("#{$project_dir}/res/autotile/#{image_path}"))
					tiles << PKMNEE::Util::AutotileImageWrapper.new(image_path)
				end
			end
			autotiles[id] = tiles
		end
		autotiles
	end

	def self.tilesets
		auto = autotiles
		puts "Importing tilesets..."
		resource_root(:graphics, "#{$rmxp_dir}/Graphics")
		tilesets = {}
		tiles = {}
		incr = 0
		safe_mkdir "#{$project_dir}/res/tile", "#{$project_dir}/data/tileset"
		Psych.load_file("#{$rmxp_dir}/export/Data/Tilesets.yaml")["root"].compact.reject { |e| e.name == '' }.each do |e| # load file and skip tilesets with no name
			tileset = PKMN::Map::Tileset.new
			tileset.id = e.name.to_id
			tileset.num = e.id
			puts "	#{tileset.id}"
			safe_mkdir "#{$project_dir}/res/tile/#{tileset.id}"
			tileset.name = e.tileset_name
			tileset_image = JavaFX::Image.new("/src/Graphics/Tilesets/#{e.tileset_name}.png")
			# autotiles
			names = e.autotile_names.unshift("").map { |s| s == "" ? "blank" : s }
			incr = 0
			names.each do |an|
				auto[auto_id = an.to_id].each do |image_wrapper|
					tile = PKMN::Map::Tile.new
					tile.id = "#{auto_id}_#{incr}"
					tile.passage = e.passages[incr]
					tile.priority = e.priorities[incr]
					tile.terrain_tag = e.terrain_tags[incr]
					tile.image = image_wrapper
					tileset.addTiles tile
					incr =+ 1
				end
			end
			# normal tiles
			tyles = []
			reader = tileset_image.getPixelReader
			(tileset_image.getHeight / 32).to_i.times do |y|
				8.times do |x|
					tile = PKMN::Map::Tile.new
					tile.id = (id = (y * 8) + x + 384)
					puts "zero" if id == 1
					tile.passage = e.passages[id]
					tile.priority = e.priorities[id]
					tile.terrain_tag = e.terrain_tags[id]
					# tile.image = JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
					tile_path = "#{tileset.id}/#{id}.png"
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::WritableImage.new(reader,x*32,y*32,32,32), nil), "png", Java::File.new("#{$project_dir}/res/tile/#{tile_path}")) # save image to file
					tile.image = PKMNEE::Util::TileImageWrapper.new(tile_path)
					tyles << tile # tiles should be in ascending order but add at index anyway to be safe
				end
			end
			tileset.image = tileset_image
			tileset.image_height = tileset_image.getHeight
			tileset.image_width = tileset_image.getWidth
			tileset.addTiles *tyles
			# tiles[tileset.id] = tyles
			tilesets[tileset.num] = tileset
			File.open("#{$project_dir}/data/tileset/#{tileset.id}.yaml", "w") do |file|
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
		tilesets
	end

	def self.maps
		ts = tilesets
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
