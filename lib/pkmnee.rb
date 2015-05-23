java_import Java::javafx.scene.control.TreeTableColumn
java_import Java::javafx.scene.control.TreeItem
java_import Java::javafx.scene.control.TreeTableView

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
				@tree_view.set_root(item)
				recursive_append_children(data["root"], item)
			elsif data.is_a?(Enumerable)
				data.each do |e|
					if e.is_a?(Array)
						item = TreeItem.new( [e[0].to_s, simple_type(e[1])] )
						recursive_append_children(e[1], item)
					else
						item = TreeItem.new( [data.index(e), simple_type(e)] )
						recursive_append_children(e, item)
					end
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