
class PKMNEE::Control::MapView < JavaFX::StackPane

	attr_accessor :map, :map_table, :layers

	def initialize(map)
		super()
		@map = map.get
		@map_table = @map.data
		@layers = []
		handler = PKMNEE::Util::EventHandler.tilePlacement
		@tileset = @map.tileset.get
		xsize = @map_table.xsize
		ysize = @map_table.ysize
		3.times do |n|
			layer = JavaFX::TilePane.new
			layer.setFocusTraversable true
			layer.setSize xsize*32, ysize*32
			ysize.times do |y|
				xsize.times do |x|
					tv = PKMNEE::Control::TileView.new(@tileset.getTile(@map_table[x, y, n]))
					tv.setOnMouseClicked handler
					tv.setFocusTraversable false
					layer.add tv
				end
			end
			getChildren.add layer
			@layers << layer
		end
		setSize @map_table.xsize*32, @map_table.ysize*32
	end
end
