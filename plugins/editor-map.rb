
class MapEditor < Java::javafx.scene.layout.BorderPane
	#include PKMNEEditor

	EDITOR_NAME = "Map Editor"

	def initialize
		create_gui
		@scene = @stage.get_scene
		get_nodes("data_tree_view", "tileset_scroll_pane", "map_stack_pane", "map_scale_slider", "map_scroll_pane")
		load_map("077")
		get_nodes("layer1_button", "layer2_button", "layer3_button")
		connect_controllers
		setup_gui
		#PKMNEEditor::DataTree.new(@map, @data_tree_view)
	end

	def setup_gui
		(@map_scroll_pane.get_children.select { |e| e.is_a?(Java::javafx.scene.control.ScrollBar) }).each { |e| e.setBlockIncrement(32) }
	end

	def connect_controllers
		add_event_handlers
		bind_properties
		format_slider_labels
	end

	def bind_properties
		@map_stack_pane.scaleXProperty.bind(@map_scale_slider.value_property)
		@map_stack_pane.scaleYProperty.bind(@map_scale_slider.value_property)
		# @map_scroll_pane.viewportBoundsProperty.bind(@map_stack_pane.boundsInParentProperty)

	end

	def format_slider_labels
		map_scale_slider_formatter = PKMNEEditor::FractionFormatter.new
		@map_scale_slider.set_label_formatter(map_scale_slider_formatter)
	end

	def add_event_handlers
		scale_listener = Java::javafx.beans.value.ChangeListener.new
		class << scale_listener
			def changed(observable, oldV, newV)
				@scroll_pane.requestLayout
			end
			def add_pane(pane)
				@scroll_pane = pane
			end
		end
		scale_listener.add_pane(@map_scroll_pane)
		@map_scale_slider.valueProperty.addListener(scale_listener)
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
			instance_variable_set("@layer#{n+1}", TilePane.new)
			instance_variable_get("@layer#{n+1}")
			set_node_size(instance_variable_get("@layer#{n+1}"), xsize*32, ysize*32)
			ysize.times do |y|
				xsize.times do |x|
					img = ImageView.new(@tileset.get_image(@map_table[x, y, n]))
					instance_variable_get("@layer#{n+1}").add(img)
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
		# @tileset_grid_pane = GridPane.new
		# @tileset_grid_pane.set_grid_lines_visible(true)
		# set_node_size(@tileset_grid_pane, @tileset.get_width, @tileset.get_height + 32)
		@tileset_tile_pane = TilePane.new
		set_node_size(@tileset_tile_pane, @tileset.get_width, @tileset.get_height + 32)
		@tileset_tile_pane.set_pref_columns(8)
		@tileset.each_image_index do |e,i|
			# @tileset_grid_pane.add(ImageView.new(e), i%8, i/8)
			@tileset_tile_pane.get_children.add(ImageView.new(e))
		end
		# @tileset_scroll_pane.set_content(@tileset_grid_pane)
		@tileset_scroll_pane.set_content(@tileset_tile_pane)
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
