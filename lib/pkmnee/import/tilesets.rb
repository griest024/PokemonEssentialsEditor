require_relative 'autotiles'

module PKMNEE::Import
	
	def self.tilesets(verbose = true)
		auto = autotiles verbose
		puts "\nImporting tilesets..."
		tilesets = {}
		tiles = {}
		incr = 0
		safe_mkdir "#{$project_dir}/res/tile", "#{$project_dir}/data/tileset"
		Psych.load_file("#{$rmxp_dir}/export/Data/Tilesets.yaml")["root"].compact.reject { |e| e.name == '' }.each.with_index do |e, i| # load file and skip tilesets with no name
			tileset = PKMN::Map::Tileset.new
			tileset.id = e.name.force_encoding("UTF-8").to_id
			tileset.num = e.id
			puts "#{i}:	#{tileset.id}" if verbose
			safe_mkdir "#{$project_dir}/res/tile/#{tileset.id}"
			tileset.name = e.tileset_name.force_encoding("UTF-8")
			tileset_image = JavaFX::Image.new(resource_url(:graphics, "Tilesets/#{tileset.name}.png").to_s)
			# autotiles
			names = e.autotile_names.unshift("").map { |s| s == "" ? "blank" : s }
			incr = 0
			names.each do |an|
				auto[auto_id = an.to_id].each do |image_wrapper|
					tile = PKMN::Map::Tile.new
					tile.id = "#{auto_id}_#{incr}".force_encoding("UTF-8")
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
					tile.passage = e.passages[id]
					tile.priority = e.priorities[id]
					tile.terrain_tag = e.terrain_tags[id]
					# tile.image = JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
					tile_path = "#{tileset.id}/#{id}.png".force_encoding("UTF-8")
					tile_image = JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
					tile_image = $blank_tile if tile_image.equals $black_tile
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(tile_image, nil), "png", Java::File.new("#{$project_dir}/res/tile/#{tile_path}")) # save image to file
					tile.image = PKMNEE::Util::TileImageWrapper.new(tile_path)
					tyles << tile # tiles should be in ascending order but add at index anyway to be safe
				end
			end
			# tileset.image = tileset_image
			tileset.image_height = tileset_image.getHeight
			tileset.image_width = tileset_image.getWidth
			tileset.addTiles *tyles
			# tiles[tileset.id] = tyles
			tilesets[tileset.num] = tileset
			File.open("#{$project_dir}/data/tileset/#{tileset.id}.yaml", "w") do |file|
				file.write tileset.to_yaml
			end
		end
		tilesets
	end
end
