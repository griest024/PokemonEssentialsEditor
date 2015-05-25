java_import Java::javafx.scene.control.TreeTableColumn
java_import Java::javafx.scene.control.TreeItem
java_import Java::javafx.scene.control.TreeTableView
java_import Java::javafx.scene.image.ImageView
java_import Java::javafx.scene.image.WritableImage
java_import Java::javafx.scene.image.Image
java_import Java::javafx.scene.layout.GridPane

module Kernel

	def simple_type?(data)
		simple_types = [Fixnum, String, FalseClass, TrueClass]
		simple_types.include?(data.class)
	end

	def simple_type(data)
		simple_type?(data) ? "#{data}" : "#{data.class}"
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
		node.set_min_width(width)
		node.set_max_width(width)
		node.set_min_height(height)
		node.set_max_height(height)
	end

	def declare_plugin(plugin_name, plugin_class)
		$plugins[plugin_name] = plugin_class
	end

end

module RPG

	class Tileset

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
			8.times do |n|
				@images << Image.new(resource_url(:images, "blank.png").to_s)
			end
			@image = Image.new(resource_url(:images, "#{tileset_name}.png").to_s)
			reader = @image.get_pixel_reader
			(@image.get_height/32).to_i.times do |y|
				8.times do |x|
					@images << WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
			# 8.times do |x|
			# 	@images << Image.new(resource_url(:images, "blank.png").to_s) 
			# 	(@image.get_height/32).to_i.times do |y|
			# 		@images << WritableImage.new(reader,x*32,y*32,32,32)
			# 	end
			# end
		end

		def get_image(id = 0)
			load_images if @images.empty?
			# row = id/8
			# col = id%8
			# puts row
			# puts col
			# num = (id%199)*8 + (id/199)
			# puts num
			id < 8 ? @images[id] : @images[id - 376]
		end

		def each_image
			load_images if @images.empty?
			@images.each do |e|
				yield(e)
			end
		end

		def each_index_image
			load_images if @images.empty?
			@images.each_index do |i|
				yield(i, @images[i])
			end
		end

		def get_tile(id)
			load_images if @images.empty?
			tile = PKMNEEditor::Tile.new
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

module PKMNEEditor

	class Tile

		attr_accessor(:image, :id, :passage, :priority, :terrain_tag, :tileset_id)
		
	end

	class DataTree

		def initialize(data, tree_view)
			@data = data
			@tree_view = tree_view
			@col1 = TreeTableColumn.new("Data")
			@col1.set_cell_value_factory(lambda do |e| 
				Java::javafx.beans.property.ReadOnlyStringWrapper.new(e.get_value.get_value[0]) 
			end )
			@col1.set_pref_width(200)
			@col2 = TreeTableColumn.new("Value")
			@col2.set_cell_value_factory(lambda do |e| 
				Java::javafx.beans.property.ReadOnlyStringWrapper.new(e.get_value.get_value[1]) 
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
				item = TreeItem.new( ["@root", simple_type(data["root"])] )
				item.set_expanded(true)
				@tree_view.set_root(item)
				recursive_append_children(data["root"], item)
			elsif data.is_a?(Hash)
				data.each do |k,v|
					item = TreeItem.new( [k.to_s, simple_type(v)] )
					parent.get_children.add(item)
					recursive_append_children(v, item)
				end
			elsif data.is_a?(Array)
				data.each_index do |i|
					item = TreeItem.new( [i.to_s, simple_type(data[i])] )
					parent.get_children.add(item)
					recursive_append_children(data[i], item)
				end
			else
				data.instance_variables.each do |e|
					value = data.instance_variable_get(e)
					item = TreeItem.new( [e.to_s, simple_type(value)] )
					parent.get_children.add(item)
					recursive_append_children(value, item)
				end
			end
		end

	end

	

end