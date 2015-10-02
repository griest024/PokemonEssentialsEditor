module griest

	module MapEditor
		
		class MapEditor < JavaFX::BorderPane
			include Controller

			loadFXML 'editor-map.fxml'

			def initialize
				loadMap("077")
				@layer_buttons = [@layer1_button, @layer2_button, @layer3_button]
				connectController
				setupGUI
				@info.setText("Loading...Done")
			end

			def setupGUI
				(@map_scroll_pane.get_children.select { |e| e.is_a?(JavaFX::ScrollBar) }).each { |e| e.setBlockIncrement(32) }
				# buildTabs
			end

			def buildTabs
				@tabs = []
				# create tool table
				3.times do |n|
					tab = JavaFX::FXMLLoader.load(getClass.getResource('/layout/map-tool-tab.fxml'))
					@tab_pane.getTabs.add(tab)
					@tabs << tab
				end
			end

			def connectController
				addEventHandlers
				bindProperties
				formatSliderLabels
			end

			def bindProperties
				#zoom slider
				@map_stack_pane.scaleXProperty.bind(@map_scale_slider.valueProperty)
				@map_stack_pane.scaleYProperty.bind(@map_scale_slider.valueProperty)
				#layer visibility buttons
				3.times do |n|
					@layer_buttons[n].selectedProperty.bindBidirectional(@layers[n].visibleProperty)
				end
			end

			def formatSliderLabels
				map_scale_slider_formatter = Util::FractionFormatter.new
				@map_scale_slider.setLabelFormatter(map_scale_slider_formatter)
			end

			def addEventHandlers
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

			def buildMap
				@map_table = @map["root"].data
				@layers = []
				xsize = @map_table.xsize
				ysize = @map_table.ysize
				3.times do |n|
					layer = JavaFX::TilePane.new
					layer.setFocusTraversable(true)
					setNodeSize(layer, xsize*32, ysize*32)
					ysize.times do |y|
						xsize.times do |x|
							img = JavaFX::ImageView.new(@tileset.getImage(@map_table[x, y, n]))
							layer.add(img)
						end
					end
					@map_stack_pane.get_children.add(layer)
					@layers << layer
				end
				setNodeSize(@map_stack_pane, @map_table.xsize*32, @map_table.ysize*32)
				# @map_stack_pane.setPickOnBounds(false)
			end

			def loadTileset(tileset_id)
				result = loadYAML("Tilesets")["root"].select do |e|
					e.id == tileset_id if e
				end
				@tileset = result[0]
				@tileset_tile_pane = JavaFX::TilePane.new
				setNodeSize(@tileset_tile_pane, @tileset.getWidth, @tileset.getHeight)
				@tileset_tile_pane.set_pref_columns(8)
				@tileset.eachImageIndex do |e,i|
					@tileset_tile_pane.getChildren.add(JavaFX::ImageView.new(e))
				end
				@tileset_scroll_pane.setContent(@tileset_tile_pane)
			end

			def loadMap(map_id)
				@map = loadYAML("Map#{map_id}")
				loadTileset(@map["root"].tileset_id)
				buildMap
			end
		end
	end
end