

class MapEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		load_map
		create_gui
	end

	def load_map
		@tileset = Gdk::Pixbuf.new($project + '/Graphics/Tilesets/Caves.png')
		
	end

	def create_gui
		@window = Gtk::Window.new
		pack_table
		@swin = Gtk::ScrolledWindow.new
		@swin.add_with_viewport(@table)
		@window.add(@swin)
		@window.show_all
	end

	def pack_table
		x = 0
		y = 0
		options = Gtk::FILL | Gtk::SHRINK
		@table = Gtk::Table.new(8, 8, true)
		@table.n_rows.times do
			@table.n_columns.times do
				@table.attach(Gtk::Image.new(Gdk::Pixbuf.new(@tileset,x*32,y*32,32,32)),x,x+1,y,y+1,options, options)
				x += 1
			end
			x = 0
			y += 1
		end
		
	end

	def self.editor_name
		EDITOR_NAME
	end



end

add_plugin("Map Editor", MapEditor)