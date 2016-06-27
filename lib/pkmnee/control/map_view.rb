
class PKMNEE::Control::MapView < JavaFX::StackPane

	attr_accessor :map, :map_table, :layers

	def initialize(map)
		super()
		@map = map.get
		@map_table = @map.data
		@layers = []
		@tileset = @map.tileset.get
		xsize = @map_table.xsize
		ysize = @map_table.ysize
		addEventHandler JavaFX::MouseEvent::ANY, lambda { |event| event.consume unless event.getButton == JavaFX::MouseButton::MIDDLE } # only pan on middle button
		3.times do |n|
			layer = JavaFX::TilePane.new
			layer.setFocusTraversable true
			layer.setSize xsize*32, ysize*32
			ysize.times do |y|
				xsize.times do |x|
					tv = PKMNEE::Control::TileView.new(@tileset.getTile(@map_table[x, y, n]))
					tv.setFocusTraversable false
					layer.add tv
				end
			end
			layer.setPrefRows @map_table.ysize
			layer.setPrefColumns @map_table.xsize
			handler = PKMNEE::Util::EventHandler.tilePlacement.init layer
			layer.getChildren.each do |tv|
				tv.setOnMouseClicked handler
				tv.setOnDragDetected handler
				tv.addEventHandler JavaFX::MouseDragEvent::ANY, handler
			end
			getChildren.add layer
			@layers << layer
		end
		# setSize @map_table.xsize*32, @map_table.ysize*32
	end
end
