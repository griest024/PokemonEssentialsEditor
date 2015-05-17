

class Editor

	

	def initialize(plugin_hash)
		@plugins = plugin_hash
		puts "Plugins loaded: #{plugin_hash}"
		create_gui
		@window.icon=(Gdk::Pixbuf.new('./res/pkball.gif'))
		@window.show_all
	end

	def open_plugin(plugin_name)
		@plugins[plugin_name].new
	end


	def create_gui
		@window = Gtk::Window.new
		@window.signal_connect("destroy") {
			Gtk.main_quit
		}
		plugin_select = Gtk::ComboBox.new
		@plugins.each do |k,v|
			plugin_select.append_text(k)		
		end
		plugin_select.signal_connect("changed") { open_plugin(plugin_select.active_text) }
		@window.add(plugin_select)
		
	end
	
end