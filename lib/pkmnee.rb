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

# modifies the official RGSS API
module RPG
	class Tileset

		attr_accessor(:images, :image, :autotiles)

		def getWidth
			loadImages if !@image
			@image.getWidth
		end

		def getHeight
			loadImages if !@image
			@image.getHeight
		end

		def loadImages
			@images = []
			@autotiles = []
			@autotile_names.unshift("").map! { |s| s == "" ? "autotile_blank" : s }
			@autotile_names.each do |e|
				autotile = []
				img = JavaFX::Image.new("/res/img/#{e}.png")
				reader = img.getPixelReader
				if img.getHeight == 128
					8.times do |y|
						6.times do |x|
							img = JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
							autotile << img
						end
					end
					$autotile_def.each do |a|
						tile = JavaFX::WritableImage.new(32, 32)
						writer = tile.getPixelWriter
						writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
						writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
						writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
						writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
						@autotiles << tile
					end
				else
					48.times {@autotiles << JavaFX::WritableImage.new(reader, 0, 0, 32, 32)}
				end
			end
			@image = JavaFX::Image.new(resource_url(:images, "#{tileset_name}.png").to_s)
			reader = @image.get_pixel_reader
			(@image.getHeight/32).to_i.times do |y|
				8.times do |x|
					@images << JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
		end

		def getImage(id = 0)
			loadImages if @images.empty?
			id < 384 ? @autotiles[id] : @images[id - 384]
		end

		def eachImageIndex
			loadImages if @images.empty?
			if block_given?
				@images.each_index do |i|
					yield(@images[i], i)
				end
			else
				return @images.each
			end
		end

		def getTile(id)
			loadImages if @images.empty?
			tile = PKMNEE::Tile.new
			tile.image=(getImage(id))
			tile.id=(id)
			tile.passage=(@passages[id])
			tile.priority=(@priorities[id])
			tile.terrain_tag=(@terrain_tags[id])
			tile.tileset_id=(@id)
		end

		def eachTile
			loadImages if @images.empty?
			@images.each_index do |i|
				yield(getTile(i))
			end
		end

	end

end

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

			loadFXML 'plugin-select.fxml'

			def initialize(tab_pane, stage)
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
					with(stage, title: plugin.to_s, width: 800, height: 600) do
						icons.add($icon)
						setMaximized(true)
						layout_scene(800, 600) do
			           		plugin.getInstance(type, *args)
			       		end
			       		show
					end
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