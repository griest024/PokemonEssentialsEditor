
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

	class Main < JRubyFX::Application

		@plugins = []

		def start(stage)
			
			with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
				fxml Editor
				setX(50)
				setY(30)
				icons.add($icon)
				setMaximized(true)
				show
			end
		end

		def stop
			super
			puts "\n********************************************************************************"
		end

		def self.load_plugins
			@plugins.map! { |e| e.new }
		end

		def self.get_instance(i, type = :default, *controller_args)
			@plugins[i].get_instance(type, *controller_args)
 		end

 		def self.names
 			@plugins.map { |p| p.class.name }
 		end

 		def self.each_name(&block)
 			self.names.each(block)
 		end

 		def self.num_plugins
 			@plugins.size
 		end

		def self.declare_plugin(plugin_class)
			plugin = plugin_class.new
			plugin.id=(@plugins.size)
			@plugins << plugin_class
		end
	end

	class Plugin
		
		NAME = "DEFAULT"
		attr_accessor(:id)
		attr_reader(:instances,  :types)

		# default_fxml=nil: specifies the optional default 
		def initialize(default_fxml = nil)
			@types = {}
			@instances = []
			add_type(:default, default_controller(default_fxml)) if default_fxml
		end

		class << self

			def inherited(subclass)
				PKMNEE::Main.declare_plugin(subclass)
				raise NotImplementedError.new("You must define class constant NAME") if !subclass.constant_defined?(:NAME)
			end

			#OVERRIDE THIS METHOD IN YOUR SUBCLASS
			def name
				NAME
			end	

		end

		def default_controller(fxml)
			# ctrl 
		end

		#type: the type of instance to get
		#*controller_args: optional args to pass to instance
		def get_instance(type, *controller_args)
			instances << ret = @types[type].new(*controller_args)
			ret
		end

		
	end

	module Util

		class FractionFormatter < Java::javafx.util.StringConverter

			def toString(dbl)
				dbl == 1 ? "1" : dbl.to_r.to_s
			end

			def fromString(str)
				str.to_r.to_f
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
			@col1.set_cell_value_factory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.get_value.get_value[0]) 
			end )
			@col1.set_pref_width(200)
			@col2 = JavaFX::TreeTableColumn.new("Value")
			@col2.set_cell_value_factory(lambda do |e| 
				JavaFX::ReadOnlyStringWrapper.new(e.get_value.get_value[1]) 
			end )
			@col2.set_pref_width(200)
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