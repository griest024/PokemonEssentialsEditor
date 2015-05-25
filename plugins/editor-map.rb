
class MapEditor < Java::javafx.scene.layout.BorderPane
	#include PKMNEEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		create_gui
		@scene = @stage.get_scene
		get_nodes("data_tree_view", "tileset_grid_pane", "map_stack_pane")
		load_map("077")
		get_nodes("layer1_button", "layer2_button", "layer3_button")
		add_event_handlers
		#PKMNEEditor::DataTree.new(@map, @data_tree_view)
	end

	def add_event_handlers
		3.times do |n|
			handler = Java::javafx.event.EventHandler.new
			class << handler
				def handle(event)
					@layer.set_visible(!@layer.visible_property.get)
				end
				def add_layer(layer)
					@layer = layer
				end
			end
			handler.add_layer(instance_variable_get("@layer#{n+1}"))
			instance_variable_get("@layer#{n+1}_button").set_on_action(handler)
		end
	end

	def build_map
		@map_table = @map["root"].data
		xsize = @map_table.xsize
		ysize = @map_table.ysize
		3.times do |n|
			instance_variable_set("@layer#{n+1}", GridPane.new())
			instance_variable_get("@layer#{n+1}")
			set_node_size(instance_variable_get("@layer#{n+1}"), xsize*32, ysize*32)
			ysize.times do |y|
				xsize.times do |x|
					img = ImageView.new(@tileset.get_image(@map_table[x, y, n]))
					instance_variable_get("@layer#{n+1}").add(img, x, y)
				end
			end
			@map_stack_pane.get_children.add(instance_variable_get("@layer#{n+1}"))
		end
		set_node_size(@map_stack_pane, @map_table.xsize*32, @map_table.ysize*32)
	end

	def load_tileset(tileset_id)
		result = load_yaml("Tilesets")["root"].select do |e|
			e.id == tileset_id if e
		end
		@tileset = result[0]
		set_node_size(@tileset_grid_pane, @tileset.get_width, @tileset.get_height + 32)
		@tileset.each_index_image do |i,e|
			@tileset_grid_pane.add(ImageView.new(e), i%8, i/8)
		end
	end

	#lookup the nodes in the scene and store them in instance variables (won't convert id to snake case!)
	def get_nodes(*fx_ids)
		fx_ids.each do |e|
			instance_variable_set("@#{e}", @scene.lookup("##{e}"))
		end
	end

	def load_map(map_id)
		@map = load_yaml("Map#{map_id}")
		load_tileset(@map["root"].tileset_id)
		build_map
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

	def self.editor_name
		EDITOR_NAME
	end



end


declare_plugin("Map Editor", MapEditor)
