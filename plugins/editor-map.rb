

class MapEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		load_map("077")
		create_gui
	end

	def load_map(mapID)
		@tileset = Gdk::Pixbuf.new($project + '/Graphics/Tilesets/Caves.png')
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/Map" + mapID + ".yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@map = parsed["root"]
	end

	def create_gui
		@window = Gtk::Window.new
		pack_table(@map.instance_variable_get(:data))
		@swin = Gtk::ScrolledWindow.new
		@swin.add_with_viewport(@table)
		@window.add(@swin)
		@window.show_all
	end

<<<<<<< HEAD


	def pack_table(mapTable)
		options = Gtk::FILL
		@mapTable = mapTable
		@table = Gtk::Table.new(8, 8, true)
		# @table.n_rows.times do
		# 	@table.n_columns.times do
		# 		@table.attach(Gtk::Image.new(Gdk::Pixbuf.new(@tileset,x*32,y*32,32,32)),x,x+1,y,y+1,options, options)
		# 	end
		# end
		mapTable.each do |e||
			File.open("dbg.txt", "w") { |file| file.puts e }
=======
	def pack_table
		options = Gtk::FILL
		@table = Gtk::Table.new(8, 8, true)
		@table.n_rows.times do |y|
			@table.n_columns.times do |x|
				@table.attach(Gtk::Image.new(Gdk::Pixbuf.new(@tileset,x*32,y*32,32,32)),x,x+1,y,y+1,options, options)
			end
>>>>>>> 6b51cd0e2974d4ac91096c7d9a4a3abbc09d6352
		end
	end

	def self.editor_name
		EDITOR_NAME
	end



end

add_plugin("Map Editor", MapEditor)