
require 'yaml'

class DataEditor

	def initialize(single_file = false)
		createGUI
	end

	def createGUI
		@window = Gtk::Window.new
		@treeStore = Gtk::TreeStore.new(String)
		YAMLtoTree()
		@treeView = Gtk::TreeView.new(@treeStore)
		rend = Gtk::CellRendererText.new
		col = Gtk::TreeViewColumn.new("Data", rend, :text => 0)
		@treeView.append_column(col)
		@window.add(@treeView)
		@window.show_all
	end

	def YAMLtoTree
		parsed = begin
  			YAML::load(File.open("#{$YAMLDir}/Map077.yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@map = parsed["root"]
		File.open("dbg.txt", "w") { |file| file.puts @map.instance_variables[0].class }
		@map.instance_variables.each do |e|
			a = @treeStore.append(nil)
			a[0] = e
		end

	end
end

add_plugin("View Raw Data", DataEditor)