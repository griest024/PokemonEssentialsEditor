
module PKMNEE::Util::EventHandler

	def self.tilePlacement
		handler = JavaFX::EventHandler.clone

		class << handler

			attr_accessor :tile_pane, :tiles

			def init(tile_pane)
				@tile_pane = tile_pane
				@tiles = @tile_pane.getChildren.to_a
				@col = @tile_pane.getPrefColumns
				@@selected_tiles = []
				@previews = []
				self
			end

			def resetTiles
				@previews.each { |e| e.deselect }
				@previews = []
			end

			def handle(event)
				if event.getButton == JavaFX::MouseButton::PRIMARY && !@@selected_tiles.empty?
					case event.getEventType.getName
					when "MOUSE_CLICKED"
						event.getSource.setTile @@selected_tiles.dig(0, 0).tile
					when "DRAG_DETECTED"
						resetTiles
						(@start = event.getSource).preview(@@selected_tiles.dig(0, 0).tile).startFullDrag
						@previews << @start
					when "MOUSE-DRAG_ENTERED"
						resetTiles
						@end = event.getSource
						([y(@start), y(@end)].min..[y(@start), y(@end)].max).each do |tile_y|
							([x(@start), x(@end)].min..[x(@start), x(@end)].max).each do |tile_x|
								@previews << tile(tile_x, tile_y).preview(@@selected_tiles.dig(tile_y % @@selected_tiles.size, tile_x % @@selected_tiles[0].size).tile) # mod to wrap around the selected tiles
							end
						end
					when "MOUSE-DRAG_RELEASED"
						resetTiles
						([y(@start), y(@end)].min..[y(@start), y(@end)].max).each do |tile_y|
							([x(@start), x(@end)].min..[x(@start), x(@end)].max).each do |tile_x|
								p tile(tile_x, tile_y).id
								p @@selected_tiles.dig(tile_y % @@selected_tiles.size, tile_x % @@selected_tiles[0].size).tile.id
								tile(tile_x, tile_y).setTile @@selected_tiles.dig(tile_y % @@selected_tiles.size, tile_x % @@selected_tiles[0].size).tile # mod to wrap around the selected tiles
							end
						end
					end
				end
			end

			def tile(x, y)
				@tiles[y * @col + x]
			end

			def xy(tile_view)
				[x(tile_view), y(tile_view)]
			end

			def x(tile_view)
				(@tiles.find_index tile_view) % @col
			end

			def y(tile_view)
				(@tiles.find_index tile_view) / @col
			end
		end
		handler
	end
end
