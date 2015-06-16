

class Editor

	include JRubyFX::Controller

	fxml 'editor-main.fxml'	

	def initialize
		PKMNEE::Main.load_plugins
		puts "Plugins loaded: #{PKMNEE::Main.names}"
		@plugin_select.get_items.set_all(PKMNEE::Main.names)
	end

	def open_plugin
		puts "Opening #{@plugin_select.get_value}..."
		plugin = PKMNEE::Main.get_instance(@plugin_select.items.index(@plugin_select.get_value))
		if true # open in tab pane
			tab = JavaFX::Tab.new
			tab.setText(@plugin_select.getValue)
			tab.setContent(plugin)
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

end