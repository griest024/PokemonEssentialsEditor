
module PKMNEE::Util::EventHandler
	
	def self.dragTileSelect(tile_pane)
		drag_handler = JavaFX::EventHandler.clone
		class << drag_handler

			attr_accessor :tile_pane, :selected_tiles, :tiles

			def init(tile_pane)
				@tile_pane = tile_pane
				@tiles = @tile_pane.getChildren.to_a
				@selected_tiles = []
			end

			def handle(event)
				case event.getEventType.getName
				when "DRAG_DETECTED"
					@selected_tiles.each { |tile| tile.deselect }
					@selected_tiles = []
					(@start = event.getSource).startFullDrag
				when "MOUSE-DRAG_ENTERED"
					@end = event.getSource
					type = :nil
					## TODO: OPTIMIZE ME PLEASE
					if x(@end) > x(@start) && y(@end) > y(@start) # nw to se
						type = :box
						@nw = @start
						@se = @end
						@ne = tile x(@se), y(@nw)
						@sw = tile x(@nw), y(@se)
					elsif x(@end) < x(@start) && y(@end) > y(@start) # ne to sw
						type = :box
						@ne = @start
						@sw = @end
						@nw = tile x(@sw), y(@ne)
						@se = tile x(@ne), y(@sw)
					elsif x(@end) > x(@start) && y(@end) < y(@start) # sw to ne
						type = :box
						@sw = @start
						@ne = @end
						@se = tile x(@ne), y(@sw)
						@nw = tile x(@sw), y(@ne)
					elsif x(@end) < x(@start) && y(@end) < y(@start) # se to nw
						type = :box
						@se = @start
						@nw = @end
						@sw = tile x(@nw), y(@se)
						@ne = tile x(@se), y(@nw)
					elsif x(@end) > x(@start) # w to e
						type = :line
					elsif x(@end) < x(@start) # e to w
						type = :line
					elsif y(@end) > y(@start) # n to s
						type = :line
					elsif y(@end) < y(@start) # s to n
						type = :line
					end
					p type
					if type == :box
						((x @nw)..(x @ne)).each do |i| # top edge
							@selected_tiles << ((tile i, y(@nw)).select :top)
						end
						((x @sw)..(x @se)).each do |i| # bottom edge
							@selected_tiles << ((tile i, y(@sw)).select :bottom)
						end
						((y @ne)..(y @se)).each do |i| # right edge
							@selected_tiles << ((tile x(@ne), i).select :right)
						end
						((y @nw)..(y @sw)).each do |i| # left edge
							@selected_tiles << ((tile x(@nw), i).select :left)
						end
						@nw.select :nw
						@ne.select :ne
						@sw.select :sw
						@se.select :se
					end
					##
				end
			end

			def tile(x, y)
				@tiles[y * 8 + x]
			end

			def xy(tile_view)
				[x(tile_view), y(tile_view)]
			end

			def x(tile_view)
				(@tiles.find_index tile_view) % @tile_pane.getPrefColumns
			end

			def y(tile_view)
				(@tiles.find_index tile_view) / @tile_pane.getPrefColumns
			end
		end
		drag_handler.init tile_pane
		drag_handler
	end
end
