
require 'yaml'

class DataEditor

	def initialize(single_file = false)
		create_gui()
	end

	def create_gui
		@window = Gtk::Window.new
		@treeStore = Gtk::TreeStore.new(String)
		yaml_to_tree()
		@treeView = Gtk::TreeView.new(@treeStore)
		rend = Gtk::CellRendererText.new
		col = Gtk::TreeViewColumn.new(@data.class.to_s, rend, :text => 0)
		@treeView.append_column(col)
		@window.add(@treeView)
		@window.show_all
	end

	def recursive_append_children(data, parent = nil)
		if data.is_a?(Enumerable)
			data.each do |e|
				a = @treeStore.append(parent)
				a[0] = "#{e.class}"
				recursive_append_children(e, a)
				
			end
		else
			data.instance_variables.each do |e|
				a = @treeStore.append(parent)
				var = data.instance_variable_get(e)
				a[0] = e.to_s + " = #{var.class}"
				recursive_append_children(var, a)
			end
		end
	end

	def yaml_to_tree
		parsed = begin
  			YAML::load(File.open("#{$YAMLDir}/Map077.yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@data = parsed["root"]
		File.open("dbg.txt", "w") { |file| file.puts @data.inspect }
		recursive_append_children(@data)
		

	end
end

add_plugin("View Raw Data", DataEditor)