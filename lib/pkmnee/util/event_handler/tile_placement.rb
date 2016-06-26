
module PKMNEE::Util::EventHandler

	def self.tilePlacement
		handler = JavaFX::EventHandler.clone

		class << handler

			def handle(event)
				p @@selected_tiles.map { |e| e.tile.id }
			end
		end

		handler
	end
end
