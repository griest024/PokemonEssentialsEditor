

class DataEditor

	def initialize
		createGUI
	end

	def createGUI
		@window = Gtk::Window.new
		
		@window.show_all
	end
end

add_plugin("View Raw Data", DataEditor)