module PKMNEE::Plugin
	class MapEditorPlugin < Base

		def initialize
			super
			types[:default] = MapEditor
			handler.maps.tilesets
		end

		class << self

			def name
				"Map Editor"
			end

			def author
				"griest"
			end
		end
		
		class MapEditor < JavaFX::BorderPane
			include JRubyFX::Controller

			fxml 'editor-map.fxml'

			def initialize
				load_map("077")
				@layer_buttons = [@layer1_button, @layer2_button, @layer3_button]
				connect_controllers
				setup_gui
				@info.setText("Loading...Done")
			end

			def setup_gui
				(@map_scroll_pane.get_children.select { |e| e.is_a?(JavaFX::ScrollBar) }).each { |e| e.setBlockIncrement(32) }
				# make_tabs
			end

			def make_tabs
				@tabs = []
				# create tool table
				3.times do |n|
					tab = JavaFX::FXMLLoader.load(getClass.getResource('/layout/map-tool-tab.fxml'))
					@tab_pane.getTabs.add(tab)
					@tabs << tab
				end
			end

			def connect_controllers
				add_event_handlers
				bind_properties
				format_slider_labels
			end

			def bind_properties
				#zoom slider
				@map_stack_pane.scaleXProperty.bind(@map_scale_slider.value_property)
				@map_stack_pane.scaleYProperty.bind(@map_scale_slider.value_property)
				#layer visibility buttons
				3.times do |n|
					@layer_buttons[n].selectedProperty.bindBidirectional(@layers[n].visibleProperty)
				end
			end

			def format_slider_labels
				map_scale_slider_formatter = PKMNEE::Util::FractionFormatter.new
				@map_scale_slider.set_label_formatter(map_scale_slider_formatter)
			end

			def add_event_handlers
				#tileset selection
				handler = JavaFX::EventHandler.new
				handler.instance_variable_set("@effect", JavaFX::InnerShadow.new)
				#click event
				def handler.handle(mouse_clicked_event)
					@node.setEffect(nil) if @node
					@node = mouse_clicked_event.getTarget
					@node.setEffect(@effect)
				end
				@tileset_tile_pane.setOnMouseClicked(handler)
				@map_stack_pane.setOnMouseClicked(handler)
				#drag event

			end

			def build_map
				@map_table = @map["root"].data
				@layers = []
				xsize = @map_table.xsize
				ysize = @map_table.ysize
				3.times do |n|
					layer = JavaFX::TilePane.new
					layer.setFocusTraversable(true)
					set_node_size(layer, xsize*32, ysize*32)
					ysize.times do |y|
						xsize.times do |x|
							img = JavaFX::ImageView.new(@tileset.get_image(@map_table[x, y, n]))
							layer.add(img)
						end
					end
					@map_stack_pane.get_children.add(layer)
					@layers << layer
				end
				set_node_size(@map_stack_pane, @map_table.xsize*32, @map_table.ysize*32)
				# @map_stack_pane.setPickOnBounds(false)
			end

			def load_tileset(tileset_id)
				result = load_yaml("Tilesets")["root"].select do |e|
					e.id == tileset_id if e
				end
				@tileset = result[0]
				@tileset_tile_pane = JavaFX::TilePane.new
				set_node_size(@tileset_tile_pane, @tileset.get_width, @tileset.get_height)
				@tileset_tile_pane.set_pref_columns(8)
				@tileset.each_image_index do |e,i|
					@tileset_tile_pane.getChildren.add(JavaFX::ImageView.new(e))
				end
				@tileset_scroll_pane.setContent(@tileset_tile_pane)
			end

			def load_map(map_id)
				@map = load_yaml("Map#{map_id}")
				load_tileset(@map["root"].tileset_id)
				build_map
			end
		end
	end
end