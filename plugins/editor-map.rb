
class MapEditor < Java::javafx.scene.layout.BorderPane
	#include PKMNEEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		create_gui
		@map = load_map("082")
		@scene = @stage.get_scene
		get_nodes("data_tree_view", "tileset_grid_pane", "map_stack_pane")
		PKMNEEditor::DataTree.new(@map, @data_tree_view)
		load_tileset
		build_map
	end

	def build_map
		layer3 = GridPane.new()
	end

	def load_tileset
		@tileset = image(resource_url(:images, 'Caves.png').to_s)
		reader = @tileset.get_pixel_reader
		@tileset_grid_pane.set_min_width(@tileset.get_width)
		@tileset_grid_pane.set_max_width(@tileset.get_width)
		@tileset_grid_pane.set_min_height(@tileset.get_height)
		@tileset_grid_pane.set_max_height(@tileset.get_height)
		(@tileset.get_height/32).to_i.times do |y|
			8.times do |x|
				@tileset_grid_pane.add(ImageView.new(WritableImage.new(reader,x*32,y*32,32,32)),x,y)
			end
		end
	end

	#lookup the nodes in the scene and store them in instance variables (won't convert id to snake case!)
	def get_nodes(*fx_ids)
		fx_ids.each do |e|
			instance_variable_set("@#{e}", @scene.lookup("##{e}"))
		end
	end

	def load_map(mapID)
		load_yaml("Map#{mapID}")
	end

	def create_gui
		@stage = Java::javafx::stage::Stage.new
		with(@stage, title: EDITOR_NAME, width: 800, height: 600) do
			fxml 'editor-map.fxml'
			#get_icons.add(image(resource_url(:images, $icon).to_s))
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
