
class PKMNEE::Control::TilesetView < JavaFX::TilePane

	attr_accessor :tile_views
	
	def initialize(tileset)
		@tileset = tileset.get

		super(*(@tile_views = tileImageViews))

		setPrefColumns 8
		setFocusTraversable true
		
		drag_handler = PKMNEE::Util::EventHandler.dragTileSelect self
		@tile_views.each do |tv|
			tv.setOnMouseClicked PKMNEE::Util::EventHandler.clickTileSelect
			tv.setOnDragDetected drag_handler
			tv.addEventHandler JavaFX::MouseDragEvent::ANY, drag_handler
		end
	end
	
	def tileImageViews
		views = []
		8.times do |n| # display only first tile of each autotile
			views << PKMNEE::Control::TileView.new(@tileset.tiles[n * 48])
		end
		@tileset.tiles[384..(@tileset.tiles.size - 384)].each { |tile| views << PKMNEE::Control::TileView.new(tile) } # add the reg tiles
		views
	end
end
