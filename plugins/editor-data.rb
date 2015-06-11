
require 'yaml'

class DataEditor < Java::javafx.scene.layout.AnchorPane
	#include PKMNEEPlugin
	include JRubyFX::Controller

	EDITOR_NAME = "Raw Data Viewer"

	fxml 'editor-data.fxml'

	def initialize()
		PKMNEEditor::DataTree.new(load_yaml("Map082"), @data_tree_view)
	end

	def get_node(fx_id)
		instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
	end
	
end

declare_plugin("View Raw Data", DataEditor)
