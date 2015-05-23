java_import Java::javafx.scene.control.TreeTableColumn
java_import Java::javafx.scene.control.TreeItem
java_import Java::javafx.scene.control.TreeTableView

class MapEditor < Java::javafx.scene.layout.BorderPane
	#include PKMNEEPlugin

	EDITOR_NAME = "Map Editor"

	def initialize
		load_map("082")
		create_gui
		@scene = @stage.get_scene
		get_node("data_tree_view")
		populate_tree_view
	end

	def populate_tree_view
		root_item = TreeItem.new("The root")
		5.times do |i|
			root_item.get_children.add(TreeItem.new("item #{i}"))
		end
		col = TreeTableColumn.new("Data")
		col.set_cell_value_factory(lambda do |e| 
			Java::javafx.beans.property.ReadOnlyStringWrapper.new(e.get_value.to_s) 
		end )
		@data_tree_view.set_root(root_item)
		@data_tree_view.get_columns.add(col)
		@data_tree_view.set_show_root(true)
	end

	#lookup the node in the scene and store it in an instance variable (won't convert id to snake case!)
	def get_node(fx_id)
		instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
	end

	def load_map(mapID)
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/Map" + mapID + ".yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		@map = parsed["root"]
	end

	def create_gui
		@stage = Java::javafx::stage::Stage.new
		with(@stage, title: EDITOR_NAME, width: 800, height: 600) do
			fxml 'editor-map.fxml'
			icons.add image(resource_url(:images, "pokeball.png").to_s)
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
