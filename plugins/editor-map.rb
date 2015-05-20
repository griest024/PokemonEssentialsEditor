

class MapEditor

	include JRubyFX::Controller

	EDITOR_NAME = "Map Editor"

	def initialize
		load_map("082")
		create_gui
	end

	def load_map(mapID)
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/Map" + mapID + ".yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@map = parsed["root"]
		@tileset = Gdk::Pixbuf.new($project + '/Graphics/Tilesets/Caves.png')
	end

	def create_gui
		@window = Gtk::Window.new
		pack_table(@map.data)
		@swin = Gtk::ScrolledWindow.new
		@swin.add_with_viewport(@table)
		@window.add(@swin)
		@window.show_all
	end



	def pack_table(mapTable)
		options = Gtk::FILL
		@table = Gtk::Table.new(mapTable.xsize, mapTable.ysize, true)
		mapData = mapTable.data
		# @table.n_rows.times do
		# 	@table.n_columns.times do
		# 		@table.attach(Gtk::Image.new(Gdk::Pixbuf.new(@tileset,x*32,y*32,32,32)),x,x+1,y,y+1,options, options)
		# 	end
		# end
		mapData.each_index do |i|
			ele = mapData[i]
			a = ele % 8
			b = ele / 8
			x = i % mapTable.xsize
			y = i / mapTable.xsize
			@table.attach(Gtk::Image.new(Gdk::Pixbuf.new(@tileset,a*32,b*32,32,32)),x,x+1,y,y+1,options, options)
		end
	end

	def self.editor_name
		EDITOR_NAME
	end



end


add_plugin("Map Editor", MapEditor)