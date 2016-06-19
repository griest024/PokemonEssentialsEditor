module PKMNEE::Control

	class TilesetTilePane < JavaFX::TilePane
		
		def initialize(tileset)
			@tileset = tileset.get
			super(*tileImageViews)
			setPrefColumns(8)
		end
		
		def tileImageViews
			views = []
			8.times do |n| # display only first tile of each autotile
				views << JavaFX::ImageView.new(@tileset.tiles[n * 48].getImage)
			end
			@tileset.tiles[384..(@tileset.tiles.size - 384)].each { |tile| views << JavaFX::ImageView.new(tile.getImage) } # add the reg tiles
			views
		end
	end
end