
module PKMNEE::Util::EventHandler
	
	def self.tileSelection(tile_pane)
		handler = JavaFX::EventHandler.clone
		class << handler

			attr_accessor :tile_pane, :tiles

			def init(tile_pane)
				@tile_pane = tile_pane
				@tiles = @tile_pane.getChildren.to_a
				@@selected_tiles = []
			end

			def clearTiles
				@@selected_tiles.each { |tile| tile.deselect }
				@@selected_tiles = []
			end

			def handle(event)
				case event.getEventType.getName
				when "MOUSE_CLICKED"
					clearTiles
					@@selected_tiles << event.getSource.select
				when "DRAG_DETECTED"
					clearTiles
					(@start = event.getSource).select.startFullDrag
				when "MOUSE-DRAG_ENTERED"
					clearTiles
					@end = event.getSource
					type = :nil
					([y(@start), y(@end)].min..[y(@start), y(@end)].max).each do |tile_y|
						([x(@start), x(@end)].min..[x(@start), x(@end)].max).each do |tile_x|
							@@selected_tiles << tile(tile_x, tile_y)
						end
					end
					## TODO: OPTIMIZE ME PLEASE
					if @start == @end
						@start.select
					elsif x(@end) > x(@start) && y(@end) > y(@start) # nw to se
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
						type = :hor
						@left = @start
						@right = @end
					elsif x(@end) < x(@start) # e to w
						type = :hor
						@left = @end
						@right = @start
					elsif y(@end) > y(@start) # n to s
						type = :ver
						@top = @start
						@bottom = @end
					elsif y(@end) < y(@start) # s to n
						type = :ver
						@top = @end
						@bottom = @start
					end
					if type == :box
						((x @nw)..(x @ne)).each do |i| # top edge
							((tile i, y(@nw)).select :top)
						end
						((x @sw)..(x @se)).each do |i| # bottom edge
							((tile i, y(@sw)).select :bottom)
						end
						((y @ne)..(y @se)).each do |i| # right edge
							((tile x(@ne), i).select :right)
						end
						((y @nw)..(y @sw)).each do |i| # left edge
							((tile x(@nw), i).select :left)
						end
						(@nw.select :nw)
						(@ne.select :ne)
						(@sw.select :sw)
						(@se.select :se)
					elsif type == :ver
						((y @top)..(y @bottom)).each do |i| # right edge
							((tile x(@top), i).select :ver)
						end
						(@top.select :no_bottom)
						(@bottom.select :no_top)
					elsif type == :hor
						((x @left)..(x @right)).each do |i| # right edge
							((tile i, y(@left)).select :hor)
						end
						(@left.select :no_right)
						(@right.select :no_left)
					end
					##
				end
			end

			def selected_tiles
				@@selected_tiles
			end

			def above(tile_view)
				tile x(tile_view), y(tile_view) - 1
			end

			def below(tile_view)
				tile x(tile_view), y(tile_view) + 1
			end

			def left(tile_view)
				tile x(tile_view) - 1, y(tile_view)
			end

			def right(tile_view)
				tile x(tile_view) + 1, y(tile_view)
			end

			def above?(tile_view)
				tv = above tile_view
				tv && @@selected_tiles.include?(tv)
			end

			def below?(tile_view)
				tv = below tile_view
				tv && @@selected_tiles.include?(tv)
			end

			def left?(tile_view)
				tv = left tile_view
				tv && @@selected_tiles.include?(tv)
			end

			def right?(tile_view)
				tv = right tile_view
				tv && @@selected_tiles.include?(tv)
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
		handler.init tile_pane
		handler
	end
end
