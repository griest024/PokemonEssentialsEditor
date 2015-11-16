#===============================================================================
# Filename:    rgss_mod.rb
#
# Developer:   Raku (rakudayo@gmail.com), griest (griest024@gmail.com)
#
# Description: This file is for any changes that may have been made directly to
#    the RPG module.  Ideally, no one should need to do this, since there are
#    the Game_* classes, but in case you did modify any classes in the RPG
#    module, you need to add those changes here for the importer exporter to
#    work.
#
#    This is required because the Marshal class needs to know the exact data
#    footprint of all the classes in the RPG module.  If new attributes are 
#    added, then the Marshal class with fail loading them from the .rxdata file.
#===============================================================================

module RPG

	class Map
		attr_accessor :id # The symbol by which the map is referred to internally - Symbol
		attr_accessor :tileset # The optional tileset can be specified for a map - Tileset
		attr_accessor :layout # The layout of the tiles - Array(Array(Tile))
		attr_accessor :encounters # The encounters for the map - EncounterList
		attr_accessor :music # Optional sound list for the map - Array(Sound)
		attr_accessor :trainers # Optional lidt of trainers that appear on the map - Hash(id: Trainer)
		attr_accessor :tiles # A list of tiles that are used to make the map - Array(Tile)
		attr_accessor :weather # A list of weather that can occur on this map - Hash(id: Weather)
		attr_accessor :region # The region this map appears in - Region

	end

	class Tile
		attr_accessor :id # The symbol by which the tile is referred to internally - Symbol
		attr_accessor :image # The appearance of the tile - Image
	end

	class Weather
		attr_accessor :id # The symbol by which the weather is referred to internally - Symbol
	end

	class Tileset

		attr_accessor :id # The symbol by which the tileset is referred to internally - Symbol
		attr_accessor :images
		attr_accessor :image
		attr_accessor :autotiles

		def getWidth
			loadImages if !@image
			@image.getWidth
		end

		def getHeight
			loadImages if !@image
			@image.getHeight
		end

		def loadImages
			@images = []
			@autotiles = []
			@autotile_names.unshift("").map! { |s| s == "" ? "autotile_blank" : s }
			@autotile_names.each do |e|
				autotile = []
				img = JavaFX::Image.new("/res/img/#{e}.png")
				reader = img.getPixelReader
				if img.getHeight == 128
					8.times do |y|
						6.times do |x|
							img = JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
							autotile << img
						end
					end
					$autotile_def.each do |a|
						tile = JavaFX::WritableImage.new(32, 32)
						writer = tile.getPixelWriter
						writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
						writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
						writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
						writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
						@autotiles << tile
					end
				else
					48.times {@autotiles << JavaFX::WritableImage.new(reader, 0, 0, 32, 32)}
				end
			end
			@image = JavaFX::Image.new(resource_url(:images, "#{tileset_name}.png").to_s)
			reader = @image.get_pixel_reader
			(@image.getHeight/32).to_i.times do |y|
				8.times do |x|
					@images << JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
		end

		def getImage(id = 0)
			loadImages if @images.empty?
			id < 384 ? @autotiles[id] : @images[id - 384]
		end

		def eachImageIndex
			loadImages if @images.empty?
			if block_given?
				@images.each_index do |i|
					yield(@images[i], i)
				end
			else
				return @images.each
			end
		end

		def getTile(id)
			loadImages if @images.empty?
			tile = PKMNEE::Tile.new
			tile.image=(getImage(id))
			tile.id=(id)
			tile.passage=(@passages[id])
			tile.priority=(@priorities[id])
			tile.terrain_tag=(@terrain_tags[id])
			tile.tileset_id=(@id)
		end

		def eachTile
			loadImages if @images.empty?
			@images.each_index do |i|
				yield(getTile(i))
			end
		end

	end
end