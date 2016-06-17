module PKMNEE::Control

	class TilesetTilePane < JavaFX::TilePane
		
		def initialize(tileset)
			@tileset = tileset.get
			super(*tileImageViews)
			setPrefColumns(8)
		end
		
		def tileImageViews
			views = []
			8.times do |n|
				views << JavaFX::ImageView.new(@tileset.tiles[n * 48].getImage)
			end
			@tileset.tiles[384..(@tileset.tiles.size - 384)].each { |tile| views << JavaFX::ImageView.new(tile.getImage) }
			views
		end
	end
end