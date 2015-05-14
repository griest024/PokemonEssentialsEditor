

class Editor

	def initialize
		@window = Gtk::Window.new
		@window.signal_connect("destroy") {
			Gtk.main_quit
		}
		@window.add(Gtk::Image.new("./res/icon.png"))
		@window.show
	end
	


end
