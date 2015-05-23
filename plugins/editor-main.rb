

class Editor

	include JRubyFX::Controller

	fxml 'editor-main.fxml'	

	def initialize
		puts "Plugins loaded: #{$plugins}"
		create_gui
	end

	def open_plugin
		$plugins[@plugin_select.get_value].new
	end

	def create_gui
		@plugin_select.get_items.set_all($plugins.keys)
		
	end
	
end