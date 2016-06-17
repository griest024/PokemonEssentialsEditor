module PKMNEE::Control

	class TilesetTilePane < JavaFX::TilePane
		
		def initialize(tileset)
			@tileset = tileset.get
			super(*tileImageViews)
			setPrefColumns(8)
		end
		
		def tileImageViews
			views = []
			@tileset.tiles.each { |tile| views << JavaFX::ImageView.new(tile.getImage) }
			views
		end
	end
end