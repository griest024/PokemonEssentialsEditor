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


class Editor
	include JRubyFX::Controller

	fxml 'editor-main.fxml'	

	def initialize
		PKMNEE::Main.load_plugins
		puts "Plugins loaded: #{PKMNEE::Main.names}"
	end

	def open_plugin_select
		stage = JavaFX::Stage.new
		select = PluginSelectController.new(@tab_pane, stage)
		with(stage, title: "Plugin Selection", width: 800, height: 600) do
			icons.add($icon)
			layout_scene(800, 600) do
				select
			end
	      	show
		end
	end

	class PluginSelectController < JavaFX::VBox
		include JRubyFX::Controller

		fxml 'plugin-select.fxml'

		def initialize(tab_pane, stage)
			@tab_pane = tab_pane
			@stage = stage
			@configs = {}
			setup_list_view
		end

		def setup_list_view
			@plugin_list.setItems(JavaFX::FXCollections.observableArrayList(PKMNEE::Main.plugins))
			@plugin_list.getSelectionModel.selectedItemProperty.java_send(\
				:addListener, [javafx.beans.value.ChangeListener], lambda do |ov,old,new|
					plugin = ov.getValue
					@configs[plugin.to_s] = plugin.config if !@configs[plugin.to_s]
					@config_pane.getChildren.setAll(@configs[plugin.to_s])
					
				end)
		end

		def open_plugin
			plugin = @plugin_list.getSelectionModel.getSelectedItem
			return if !plugin
			config = @configs[plugin.to_s]
			if !config.is_a?(JavaFX::Label)
				args = config.args
				type = config.type
			else
				args = []
				type = :default
			end
			puts "Opening #{plugin}..."
			if @window_checkbox.isSelected # open in new window
				stage = JavaFX::Stage.new
				with(stage, title: plugin.to_s, width: 800, height: 600) do
					icons.add($icon)
					setMaximized(true)
					layout_scene(800, 600) do
		           		plugin.get_instance(type, *args)
		       		end
		       		show
				end
			else # open in tab pane
				tab = JavaFX::Tab.new
				tab.setText(plugin.to_s)
				tab.setContent(plugin.get_instance(type, *args))
				@tab_pane.getTabs.add(tab)
			end
			@stage.close
		end
		
	end
end