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


###############################################################################

# stores the RGSS autotile definition
$autotile_def = [
	[26, 27, 32, 33],
	[4, 27, 32, 33],
	[26, 5, 32, 33],
	[4, 5, 32, 33],
	[26, 27, 32, 11],
	[4, 27, 32, 11],
	[26, 5, 32, 11],
	[4, 5, 32, 11],
	[26, 27, 10, 33],
	[4, 27, 10, 33],
	[26, 5, 10, 33],
	[4, 5, 10, 33],
	[26, 27, 10, 11],
	[4, 27, 10, 11],
	[26, 5, 10, 11],
	[4, 5, 10, 11],
	[24, 27, 30, 33],
	[24, 5, 30, 33],
	[24, 27, 30, 11],
	[24, 5, 30, 11],
	[14, 15, 32, 33],
	[14, 15, 32, 11],
	[14, 15, 10, 33],
	[14, 15, 10, 11],
	[26, 29, 32, 35],
	[26, 29, 10, 35],
	[4, 29, 32, 35],
	[4, 29, 10, 35],
	[26, 27, 44, 45],
	[4, 27, 44, 45],
	[26, 5, 44, 45],
	[4, 5, 44, 45],
	[24, 29, 30, 35],
	[14, 15, 44, 45],
	[12, 13, 18, 19],
	[12, 13, 18, 11],
	[16, 17, 22, 23],
	[16, 17, 10, 23],
	[40, 41, 46, 47],
	[4, 41, 46, 47],
	[36, 37, 42, 43],
	[36, 5, 42, 43],
	[12, 17, 18, 23],
	[12, 13, 42, 43],
	[36, 41, 42, 47],
	[22, 23, 46, 47],
	[12, 17, 42, 47],
	[0, 1, 6, 7]
]

module PKMNEE

	# class PluginManager
		
	# 	def initialize(plugins)
	# 		@plugins = []
	# 		@plugins = plugins
	# 	end
		
	# 	def self.get_instance(i, type = :default, *controller_args)
	# 		@plugins[i].get_instance(type, *controller_args)
 # 		end

 # 		def self.names
 # 			@plugins.map { |p| p.class.name }
 # 		end

 # 		def self.num_plugins
 # 			@plugins.size
 # 		end

	# end

	class Main < JRubyFX::Application

		@plugins = []

		def start(stage)
			@stage = stage
			with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
				fxml Editor
				setX(50)
				setY(30)
				icons.add($icon)
				setMaximized(true)
				show
			end
		end

		#DELETE
		def self.plugins
			@plugins
		end
		#DELETE

		def stop
			super
			puts "\n********************************************************************************"
		end

		def self.load_plugins
			# @manager = PluginManager.new(@plugins)
			@plugins.map! { |e| e.new }
			@plugins.each_index { |i| @plugins[i].id= i }
		end

		def self.names
 			@plugins.map { |p| p.class.name }
 		end

 		def self.get_instance(i, type = :default, *controller_args)
			@plugins[i].get_instance(type, *controller_args)
 		end

 		def self.each_name(&block)
 			self.names.each(block)
 		end

 		def self.num_plugins
 			@plugins.size
 		end

		def self.declare_plugin(plugin_class)
			# plugin = plugin_class.new
			# plugin.id=(@plugins.size)
			@plugins << plugin_class
		end
	end

	class Editor
		include JRubyFX::Controller

		fxml 'editor-main.fxml'	

		def initialize
			Main.load_plugins
			puts "Plugins loaded: #{Main.names}"
		end

		def openPluginSelect
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
				setupListView
			end

			def setupListView
				@plugin_list.setItems(JavaFX::FXCollections.observableArrayList(PKMNEE::Main.plugins))
				@plugin_list.getSelectionModel.selectedItemProperty.java_send(:addListener, [javafx.beans.value.ChangeListener], lambda do |ov,old,new|
						plugin = ov.getValue
						@configs[plugin.to_s] = plugin.config if !@configs[plugin.to_s]
						@config_pane.getChildren.setAll(@configs[plugin.to_s])
						
					end)
			end

			def openPlugin
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
					@tab_pane.getSelectionModel.select(tab)
				end
				@stage.close
			end
			
		end
	end

	class DataTree

		def initialize(data, tree_view)
			@data = data
			@tree_view = tree_view
			@col1 = JavaFX::TreeTableColumn.new("Data")
			@col1.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.get_value.get_value[0]) 
			end )
			@col1.set_pref_width(200)
			@col2 = JavaFX::TreeTableColumn.new("Value")
			@col2.setCellValueFactory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.get_value.get_value[1]) 
			end )
			@col2.setPrefWidth(200)
			populateTreeView
		end

		def populateTreeView
			recursiveAppendChildren(@data)
			@tree_view.get_columns.addAll(@col1, @col2)
			@tree_view.set_show_root(true)
		end

		def recursiveAppendChildren(data, parent = nil)
			if !parent
				item = JavaFX::TreeItem.new( ["@root", simpleType(data["root"])] )
				item.setExpanded(true)
				@tree_view.setRoot(item)
				recursiveAppendChildren(data["root"], item)
			elsif data.is_a?(Hash)
				data.each do |k,v|
					item = JavaFX::TreeItem.new( [k.to_s, simpleType(v)] )
					parent.get_children.add(item)
					recursiveAppendChildren(v, item)
				end
			elsif data.is_a?(Array)
				data.each_index do |i|
					item = JavaFX::TreeItem.new( [i.to_s, simpleType(data[i])] )
					parent.get_children.add(item)
					recursiveAppendChildren(data[i], item)
				end
			else
				data.instance_variables.each do |e|
					value = data.instance_variable_get(e)
					item = JavaFX::TreeItem.new( [e.to_s, simpleType(value)] )
					parent.get_children.add(item)
					recursiveAppendChildren(value, item)
				end
			end
		end
	end
end