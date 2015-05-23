
class MapEditor < Java::javafx.scene.layout.BorderPane
	#include PKMNEEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		@map = load_map("082")
		create_gui
		@scene = @stage.get_scene
		get_node("data_tree_view")
		PKMNEEditor::DataTree.new(@map, @data_tree_view)
	end

	#lookup the node in the scene and store it in an instance variable (won't convert id to snake case!)
	def get_node(fx_id)
		instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
	end

	def load_map(mapID)
		load_yaml("Map#{mapID}")
	end

	def create_gui
		@stage = Java::javafx::stage::Stage.new
		with(@stage, title: EDITOR_NAME, width: 800, height: 600) do
			fxml 'editor-map.fxml'
			icons.add(image(resource_url(:images, "pokeball.png").to_s))
			init_owner(PKMNEEditorApp.get_main_window)
			show
		end
	end

	def pack_table(mapTable)
		mapData = mapTable.data
		mapData.each_index do |i|
			ele = mapData[i]
			a = ele % 8
			b = ele / 8
			x = i % mapTable.xsize
			y = i / mapTable.xsize
		end
	end

	def self.editor_name
		EDITOR_NAME
	end



end


declare_plugin("Map Editor", MapEditor)
