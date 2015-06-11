

class Editor

	include JRubyFX::Controller

	fxml 'editor-main.fxml'	

	def initialize
		puts "Plugins loaded: #{$plugins}"
		create_gui
	end

	def open_plugin
		puts "Opening #{@plugin_select.get_value}..."
		plugin = $plugins[@plugin_select.get_value]
		if true # open in tab pane
			tab = JavaFX::Tab.new
			tab.setText(@plugin_select.getValue)
			tab.setContent(plugin.new)
			@tab_pane.getTabs.add(tab)
		else # open in new window (non-modal)
			stage = JavaFX::Stage.new
			with(stage, title: @plugin_select.get_value, width: 800, height: 600) do
				icons.add($icon)
				setMaximized(true)
				layout_scene(800, 600) do
	           		plugin.new
	       		end
	       		show
			end
		end
	end

	def create_gui
		@plugin_select.get_items.set_all($plugins.keys)
		
	end
	
end