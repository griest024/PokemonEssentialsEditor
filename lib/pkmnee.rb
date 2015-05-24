java_import Java::javafx.scene.control.TreeTableColumn
java_import Java::javafx.scene.control.TreeItem
java_import Java::javafx.scene.control.TreeTableView
java_import Java::javafx.scene.image.ImageView
java_import Java::javafx.scene.image.WritableImage
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

	def declare_plugin(plugin_name, plugin_class)
		$plugins[plugin_name] = plugin_class
	end

end

module PKMNEEditor

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