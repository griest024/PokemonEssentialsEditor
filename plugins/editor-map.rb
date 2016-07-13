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

			class ToolBar < JavaFX::ToolBar
				include JRubyFX::Controller

				fxml 'plugin/map/toolbar.fxml'

				attr_reader :layer1_button, :layer2_button, :layer3_button, :map_scale_slider

				def initialize;	end # JRubyFX::Controller needs this for some reason
			end

			fxml 'plugin/map/map-view.fxml'

			attr_reader :toolbar

			def initialize(map = nil)
				@toolbar = ToolBar.new
				@layer_buttons = [@toolbar.layer1_button, @toolbar.layer2_button, @toolbar.layer3_button]
				@map_scale_slider = @toolbar.map_scale_slider

				if map
					loadMap(map.get)
				else
					
				end

				bindProperties
				
				# format sliders
				@map_scale_slider.set_label_formatter PKMNEE::Util::FractionFormatter.new

				setTop @toolbar unless getParent.is_a? JavaFX::Tab

				@info.setText "Loading...Done"
			end

			def unbindProperties
				# zoom slider

			end

			def bindProperties
				# zoom slider
				@map_stack_pane.scaleXProperty.bind @map_scale_slider.value_property
				@map_stack_pane.scaleYProperty.bind @map_scale_slider.value_property

				# layer visibility buttons
				3.times do |n|
					@layer_buttons[n].selectedProperty.bindBidirectional @map_stack_pane.layers[n].visibleProperty
				end
			end

			def loadMap(map)
				@map_stack_pane = PKMNEE::Control::MapView.new map.get
				@tileset_tile_pane = PKMNEE::Control::TilesetView.new map.tileset.get
				@map_scroll_pane.setContent @map_stack_pane
				@tileset_scroll_pane.setContent @tileset_tile_pane 
			end
		end
	end
end