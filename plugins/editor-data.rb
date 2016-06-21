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

require 'yaml'

module PKMNEE::Plugin
	class RawData < Base

		class << self

			def init
				@handler = DataHandler.new(RawDataView).handleAll
				@name = "Raw Data"
				@author = "griest"
				@description = "Allows you to view the attributes of all the data associated with your game"
			end

		end

		class RawDataView < JavaFX::VBox

			def initialize(data = nil)
				super()
				setMaxHeight Java::Double::MAX_VALUE
				if data # load a discrete set of data
					getChildren.add PKMNEE::Control::DataTreeView.new(data)
				else # load everything
					@accordion = JavaFX::Accordion.new
					$data.each do |k,v|
						lv = JavaFX::ListView.new(JavaFX::FXCollections.observableArrayList(v.wrappers.values))
						lv.setOnMouseClicked lambda { |click| PKMNEE::Main.openInTab lv.getSelectionModel.getSelectedItem.get if click.getClickCount == 2 }
						open_tab = JavaFX::MenuItem.new("Open in tab")
						open_tab.setOnAction lambda { |event| PKMNEE::Main.openInTab(lv.getSelectionModel.getSelectedItem.get) }
						open_window = JavaFX::MenuItem.new("Open in window")
						open_window.setOnAction lambda { |event| PKMNEE::Main.openInWindow(lv.getSelectionModel.getSelectedItem.get) }
						menu = JavaFX::ContextMenu.new(open_tab, open_window)
						lv.setContextMenu menu
						@accordion.getPanes.add JavaFX::TitledPane.new(k.to_s, lv)
					end
					@accordion.setMaxHeight Java::Double::MAX_VALUE
					# @accordion.expandedPaneProperty.addListener lambda { |ov, old, new| ov.getValue.getContent.loadChildren }
					getChildren.add @accordion
				end
			end
		end
	end
end

