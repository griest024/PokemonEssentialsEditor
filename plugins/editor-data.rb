
require 'yaml'

class DataEditor

	include JRubyFX::Controller

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

	def simple_type(data)
		simple_types = [Fixnum, String, FalseClass, TrueClass]
		check = false
		simple_types.each do |e|
			check = check || data.is_a?(e)
		end
		check ? "#{data}" : "#{data.class}"
	end


	def recursive_append_children(data, parent = nil)
		if data.is_a?(Enumerable)
			data.each do |e|
				a = @treeStore.append(parent)
				if e.is_a?(Array)
					a[0] = "#{e[0]}: " + simple_type(e[1])
				else
					a[0] = simple_type(e)
				end
				recursive_append_children(e, a)
			end
		else
			data.instance_variables.each do |e|
				a = @treeStore.append(parent)
				var = data.instance_variable_get(e)
				a[0] = e.to_s + " = " + simple_type(var)
				recursive_append_children(var, a)
			end
		end
	end

	def yaml_to_tree
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/Map082.yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@data = parsed["root"]
		File.open("dbg.txt", "w") { |file| file.puts @data.inspect }
		recursive_append_children(@data)
		

	end
end

add_plugin("View Raw Data", DataEditor)