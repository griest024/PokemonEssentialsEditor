
class PKMNEE::Control::TilesetView < JavaFX::TilePane

	attr_accessor :tile_views
	
	def initialize(tileset)
		@tileset = tileset.get

		super(*(@tile_views = tileImageViews))

		setPrefColumns 8
		setFocusTraversable true
		
		handler = PKMNEE::Util::EventHandler.tileSelection.init self
		@tile_views.each do |tv|
			tv.setOnMouseClicked handler
			tv.setOnDragDetected handler
			tv.addEventHandler JavaFX::MouseDragEvent::ANY, handler
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
