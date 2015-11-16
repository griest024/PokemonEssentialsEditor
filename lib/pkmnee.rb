=begin
    Copyright (C) 2015 - Peter Lauck (griest)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.
=end

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
		
	# 	def self.getInstance(i, type = :default, *controller_args)
	# 		@plugins[i].getInstance(type, *controller_args)
 # 		end

 # 		def self.names
 # 			@plugins.map { |p| p.class.name }
 # 		end

 # 		def self.numPlugins
 # 			@plugins.size
 # 		end

	# end

	class Main < JavaFX::Application

		

		def start(stage)
			@stage = stage
			@stage.setTitle("Pokemon Essentials Editor")
			@stage.setX(50)
			@stage.setY(30)
			@stage.icons.add $icon
			@stage.setMaximized(true)
			@stage.show
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

		def self.loadPlugins
			# @manager = PluginManager.new(@plugins)
			@plugins.map! { |e| e.new }
			@plugins.each_index { |i| @plugins[i].id= i }
		end

		def self.names
 			@plugins.map { |p| p.class.name }
 		end

 		def self.getInstance(i, type = :default, *controller_args)
			@plugins[i].getInstance(type, *controller_args)
 		end

 		def self.eachName(&block)
 			self.names.each(block)
 		end

 		def self.numPlugins
 			@plugins.size
 		end

		def self.declarePlugin(plugin_class)
			# plugin = plugin_class.new
			# plugin.id=(@plugins.size)
			@plugins << plugin_class
		end

		private attr_accessor(plugins)
	end

	class Editor
		include Plugin::Controller

		def initialize
			loadFXML 'editor-main.fxml'
			Main.loadPlugins
			puts "Plugins loaded: #{Main.names}"
		end

		def openPluginSelect
			stage = JavaFX::Stage.new
			select = PluginSelectController.new(@tab_pane, stage)
			stage.setWidth(800)
			stage.setHeight(600)
			stage.setTitle("Plugin Selection")
			stage.icons.add($icon)
			stage.setScene(JavaFX::Scene.new(select, 800, 600))
			stage.show
		end

		class PluginSelectController < JavaFX::VBox
			include Plugin::Controller

			def initialize(tab_pane, stage)
				loadFXML('plugin-select.fxml')
				@tab_pane = tab_pane
				@stage = stage
				@configs = {}
				setupListView
			end

			def setupListView
				@plugin_list.setItems(JavaFX::FXCollections.observableArrayList(PKMNEE::Main.plugins))
				@plugin_list.getSelectionModel.selectedItemProperty.java_send(\
					:addListener, [javafx.beans.value.ChangeListener], lambda do |ov,old,new|
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
					stage.setTitle(plugin.to_s)
					stage.setWidth(800)
					stage.setHeight(600)
					stage.icons.add($icon)
					stage.setMaximized(true)
					stage.setScene(plugin.getInstance(type, *args))
					stage.show
				else # open in tab pane
					tab = JavaFX::Tab.new
					tab.setText(plugin.to_s)
					tab.setContent(plugin.getInstance(type, *args))
					@tab_pane.getTabs.add(tab)
					@tab_pane.getSelectionModel.select(tab)
				end
				@stage.close
			end
			
		end
	end

	class Tile

		attr_accessor(:image, :id, :passage, :priority, :terrain_tag, :tileset_id)
		
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
			@tree_view.getColumns.addAll(@col1, @col2)
			@tree_view.setShowRoot(true)
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
					parent.getChildren.add(item)
					recursiveAppendChildren(v, item)
				end
			elsif data.is_a?(Array)
				data.each_index do |i|
					item = JavaFX::TreeItem.new( [i.to_s, simpleType(data[i])] )
					parent.getChildren.add(item)
					recursiveAppendChildren(data[i], item)
				end
			else
				data.instance_variables.each do |e|
					value = data.instance_variable_get(e)
					item = JavaFX::TreeItem.new( [e.to_s, simpleType(value)] )
					parent.getChildren.add(item)
					recursiveAppendChildren(value, item)
				end
			end
		end
	end
end