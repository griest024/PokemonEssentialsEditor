
module PKMNEE::Util::EventHandler
	
	def self.clickTileSelect
		click_handler = JavaFX::EventHandler.clone
		def click_handler.handle(event)
			@tile.deselect if @tile
			@tile = event.getSource
			@tile.select
		end
		click_handler
	end
end
