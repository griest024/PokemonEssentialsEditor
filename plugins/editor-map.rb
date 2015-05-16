

class MapEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		createGUI
	end

	def createGUI
		@window = Gtk::Window.new
		@window.show_all
	end

	def self.editor_name
		EDITOR_NAME
	end



end

add_plugin("Map Editor", MapEditor)