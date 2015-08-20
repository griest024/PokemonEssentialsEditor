
module Kernel

	def simple_type?(data)
		simple_types = [Fixnum, String, FalseClass, TrueClass]
		simple_types.include?(data.class)
	end

	def simple_type(data)
		simple_type?(data) ? "#{data}" : "#{data.class}, ID: #{data.object_id}"
	end

	def load_yaml(filename)
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/#{filename}.yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		parsed
	end

	def set_node_size(node, width, height)
		node.setMinWidth(width)
		node.setMaxWidth(width)
		node.setMinHeight(height)
		node.setMaxHeight(height)
	end
end

module RPG

	class Tileset

		attr_accessor(:images, :image, :autotiles)

		def get_width
			load_images if !@image
			@image.get_width
		end

		def get_height
			load_images if !@image
			@image.get_height
		end

		def load_images
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
			(@image.get_height/32).to_i.times do |y|
				8.times do |x|
					@images << JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
		end

		def get_image(id = 0)
			load_images if @images.empty?
			id < 384 ? @autotiles[id] : @images[id - 384]
		end

		def each_image_index
			load_images if @images.empty?
			if block_given?
				@images.each_index do |i|
					yield(@images[i], i)
				end
			else
				return @images.each
			end
		end

		def get_tile(id)
			load_images if @images.empty?
			tile = PKMNEE::Tile.new
			tile.image=(get_image(id))
			tile.id=(id)
			tile.passage=(@passages[id])
			tile.priority=(@priorities[id])
			tile.terrain_tag=(@terrain_tags[id])
			tile.tileset_id=(@id)
		end

		def each_tile
			load_images if @images.empty?
			@images.each_index do |i|
				yield(get_tile(i))
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

	module Plugin
		class Base
			
			attr_accessor(:id)
			attr_reader(:instances,  :types, :handler)

			def initialize
				@types = {}
				@instances = []
				@handler = FileHandler.new
			end

			class << self

				def inherited(subclass)
					PKMNEE::Main.declare_plugin(subclass)
				end

				def name
					raise NotImplementedError.new("You must override self.name")
				end

				def author
					raise NotImplementedError.new("You must override self.author")
				end

			end

			def can_handle?(type)
				@handler.can_handle?(type)
			end

			def description
				"Author has not added a description. You're on your own."
			end

			# returns the default configuration screen
			def config
				JavaFX::Label.new("This plugin has no configurable options.")
			end

			#type: the type of instance to get
			#*controller_args: optional args to pass to instance
			def get_instance(type, *controller_args)
				instances << ret = @types[type].new(*controller_args)
				ret
			end

			def to_s
				self.class.name
			end

			# Needed so JavaFX can convert this object to a String
			def toString
				to_s
			end

			class Config
				include JRubyFX::Controller

				def initialize

				end

				# returns the selected type of instance to open, will pass to get_instance
				def type
					:default
				end

				# returns the configured args to pass to controller, will pass to get_instance
				def args
					
				end
			end

			# specifies which files a plugin can open
			class FileHandler

				def initialize(*types)
					@types = []
					add_handle(*types)
				end

				def can_handle?(type)
					@types.include?(type)
				end

				# specifies that the plugin can handle files of type
				def add_handle(*type)
					type.each { |e| @types << e }
					@types
				end

				def scripts
					add_handle(:Scripts)
					self
				end

				def maps
					add_handle(:Maps)
					self
				end

				def skills
					add_handle(:Skills)
					self
				end

				def states
					add_handle(:States)
					self
				end

				def system
					add_handle(:System)
					self
				end

				def tilesets
					add_handle(:Tilesets)
					self
				end

				def troops
					add_handle(:Troops)
					self
				end

				def weapons
					add_handle(:Weapons)
					self
				end

				def animations
					add_handle(:Animations)
					self
				end

				def actors
					add_handle(:Actors)
					self
				end

				def armors
					add_handle(:Armors)
					self
				end

				def classes
					add_handle(:Classes)
					self
				end

				def common_events
					add_handle(:CommonEvents)
					self
				end

				def constants
					add_handle(:Constants)
					self
				end

				def enemies
					add_handle(:Enemies)
					self
				end

				def items
					add_handle(:Items)
					self
				end
			end
		end
	end

	module Util

		class FractionFormatter < JavaFX::StringConverter

			def toString(dbl)
				dbl == 1 ? "1" : dbl.to_r.to_s
			end

			def fromString(str)
				str.to_r.to_f
			end
		end

		#NOT USED
		class PluginListCell < JavaFX::ListCell
			
			def update_item(item, empty)
				super(item, empty)
				setText(item.class.name) if item != null
			end
		end
		#NOT USED
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
			populate_tree_view
		end

		def populate_tree_view
			recursive_append_children(@data)
			@tree_view.get_columns.addAll(@col1, @col2)
			@tree_view.set_show_root(true)
		end

		def recursive_append_children(data, parent = nil)
			if !parent
				item = JavaFX::TreeItem.new( ["@root", simple_type(data["root"])] )
				item.set_expanded(true)
				@tree_view.set_root(item)
				recursive_append_children(data["root"], item)
			elsif data.is_a?(Hash)
				data.each do |k,v|
					item = JavaFX::TreeItem.new( [k.to_s, simple_type(v)] )
					parent.get_children.add(item)
					recursive_append_children(v, item)
				end
			elsif data.is_a?(Array)
				data.each_index do |i|
					item = JavaFX::TreeItem.new( [i.to_s, simple_type(data[i])] )
					parent.get_children.add(item)
					recursive_append_children(data[i], item)
				end
			else
				data.instance_variables.each do |e|
					value = data.instance_variable_get(e)
					item = JavaFX::TreeItem.new( [e.to_s, simple_type(value)] )
					parent.get_children.add(item)
					recursive_append_children(value, item)
				end
			end
		end
	end
end