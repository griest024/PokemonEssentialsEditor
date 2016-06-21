 #    Copyright (C) 2015 - Peter Lauck (griest)

 #    This program is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU General Public License as published by
 #    the Free Software Foundation, either version 3 of the License, or
 #    (at your option) any later version.

 #    This program is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU General Public License for more details.

 #    You should have received a copy of the GNU General Public License
 #    along with this program.  If not, see <http://www.gnu.org/licenses/>.

module PKMNEE::Plugin

	class MapEditor < Base

		$default_plugins[:map] = self

		class << self

			def init
				@name = "Map Editor"
				@author = "griest"
				@description = "You can edit maps, tilesets, tiles, and the world map with this plugin."
				@handler = DataHandler.new(MapView).handleAll
			end
		end
		
		class MapView < JavaFX::BorderPane
			include JRubyFX::Controller

			fxml 'editor-map.fxml'

			def initialize(map = nil)
				if map
					loadMap(map.get)
				else
					
				end
				@layer_buttons = [@layer1_button, @layer2_button, @layer3_button]
				# addEventHandlers
				bindProperties
				formatSliderLabels
				setupGUI
				@info.setText "Loading...Done"
			end

			def setupGUI
				# @map_scroll_pane.getStylesheets.add "/res/css/map-editor.css"
				# makeTabs
			end

			def makeTabs
				@tabs = []
				# create tool table
				3.times do |n|
					tab = JavaFX::FXMLLoader.load(getClass.getResource('/layout/map-tool-tab.fxml'))
					@tab_pane.getTabs.add(tab)
					@tabs << tab
				end
			end

			def unbindProperties
				# zoom slider

			end

			def bindProperties
				#zoom slider
				@map_stack_pane.scaleXProperty.bind(@map_scale_slider.value_property)
				@map_stack_pane.scaleYProperty.bind(@map_scale_slider.value_property)
				#layer visibility buttons
				3.times do |n|
					@layer_buttons[n].selectedProperty.bindBidirectional(@map_stack_pane.layers[n].visibleProperty)
				end
			end

			def formatSliderLabels
				# map_scale_slider_formatter = PKMNEE::Util::FractionFormatter.new
				@map_scale_slider.set_label_formatter(PKMNEE::Util::FractionFormatter.new)
			end

			def addEventHandlers
				#tileset selection
				handler = JavaFX::EventHandler.new
				handler.instance_variable_set(:@effect, JavaFX::InnerShadow.new)
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
					@map_stack_pane.getChildren.add(layer)
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
				setNodeSize(@tileset_tile_pane, @tileset.get_width, @tileset.get_height)
				@tileset_tile_pane.set_pref_columns(8)
				@tileset.each_image_index do |e,i|
					@tileset_tile_pane.getChildren.add(JavaFX::ImageView.new(e))
				end
				@tileset_scroll_pane.setContent(@tileset_tile_pane)
			end

			def loadMap(map)
				@map_stack_pane = PKMNEE::Control::MapStackPane.new(map.get)
				@tileset_tile_pane = PKMNEE::Control::TilesetTilePane.new(map.tileset.get)
				@map_group.getChildren.setAll(@map_stack_pane)
				@tileset_scroll_pane.setContent(@tileset_tile_pane)
			end
		end
	end
end