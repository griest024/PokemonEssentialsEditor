module PKMNEE::Control
	
	class MapStackPane < JavaFX::StackPane

		attr_accessor :map, :map_table, :layers

		def initialize(map)
			super()
			@map = map.get
			@map_table = @map.data
			@layers = []
			@tileset = @map.tileset.get
			xsize = @map_table.xsize
			ysize = @map_table.ysize
			3.times do |n|
				layer = JavaFX::TilePane.new
				layer.setFocusTraversable true
				layer.setSize(xsize*32, ysize*32)
				ysize.times do |y|
					xsize.times do |x|
						# img = JavaFX::ImageView.new(@tileset.get_image(@map_table[x, y, n]))
						layer.add JavaFX::ImageView.new(@tileset.getImage(@map_table[x, y, n]))
					end
				end
				getChildren.add layer
				@layers << layer
			end
			setSize(@map_table.xsize*32, @map_table.ysize*32)
		end
		
		
	end
end