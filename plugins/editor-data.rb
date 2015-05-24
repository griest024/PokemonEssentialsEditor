
require 'yaml'

class DataEditor < Java::javafx.scene.layout.Pane
	#include PKMNEEPlugin

	EDITOR_NAME = "Raw Data Viewer"

	def initialize()
		create_gui
		@scene = @stage.get_scene
		get_node("data_tree_view")
		PKMNEEditor::DataTree.new(load_yaml("Map082"), @data_tree_view)
	end

	def get_node(fx_id)
		instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
	end

	def create_gui
		@stage = Java::javafx::stage::Stage.new
		with(@stage, title: EDITOR_NAME, width: 800, height: 600) do
			fxml 'editor-data.fxml'
			#get_icons.add(image(resource_url(:images, $icon).to_s))
			init_owner(PKMNEEditorApp.get_main_window)
			show
		end
	end


	
end

declare_plugin("View Raw Data", DataEditor)
