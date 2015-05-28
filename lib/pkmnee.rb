java_import Java::javafx.scene.control.TreeTableColumn
java_import Java::javafx.scene.control.TreeItem
java_import Java::javafx.scene.control.TreeTableView
java_import Java::javafx.scene.image.ImageView
java_import Java::javafx.scene.image.WritableImage
java_import Java::javafx.scene.image.Image
java_import Java::javafx.scene.layout.GridPane
java_import Java::javafx.scene.control.Slider
java_import Java::javafx.util.StringConverter
java_import Java::javafx.scene.layout.TilePane

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

		attr_accessor(:images, :autotiles, :image)

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
			@autotile_names.unshift("").map! { |s| s == "" ? "blank" : s }
			# blank = Image.new(resource_url(:images, "blank.png").to_s)
			@autotile_names.each do |e|
				img = Image.new(resource_url(:images, "#{e}.png").to_s)
				reader = img.get_pixel_reader
				@images << WritableImage.new(reader, 0, 0, 32, 32)
				# i = 0
				# row = (img.get_height/32).to_i
				# col = (img.get_width/32).to_i
				# puts e
				# puts "row #{row}"
				# puts "col #{col}"
				# row.times do |y|
				# 	col.times do |x|
				# 		@autotiles << WritableImage.new(reader,x*32,y*32,32,32)
				# 		i += 1
				# 	end
				# end
				# puts "num #{i} size #{@autotiles.size}"
				# if i < 47
				# 	(47 - i).times do |n|
				# 		@autotiles << blank
				# 	end
				# end
			end
			@image = Image.new(resource_url(:images, "#{tileset_name}.png").to_s)
			reader = @image.get_pixel_reader
			(@image.get_height/32).to_i.times do |y|
				8.times do |x|
					@images << WritableImage.new(reader,x*32,y*32,32,32)
				end
			end
		end

		def get_image(id = 0)
			load_images if @images.empty?
			id < 384 ? @images[(id / 48).to_i] : @images[id - 376]
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

	class FractionFormatter < Java::javafx.util.StringConverter
		def toString(dbl)
			dbl == 1 ? "1" : dbl.to_r.to_s
		end
		def fromString(str)
			str.to_r.to_f
		end
	end

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