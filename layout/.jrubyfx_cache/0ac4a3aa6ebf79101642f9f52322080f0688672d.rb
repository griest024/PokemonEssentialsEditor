# 946e9357b5600c1fec01fbf200156c4e83f27174 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2015-05-24 20:52:35 -0400 for /home/griest/pkmn-editor/PokemonEssentialsEditor/layout/editor-map.fxml
########################### DO NOT MODIFY THIS FILE ###########################

module JRubyFX
  module GeneratedAssets
    class AOT0ac4a3aa6ebf79101642f9f52322080f0688672d
      include JRubyFX
          def __build_via_jit(__local_fxml_controller, __local_namespace, __local_jruby_ext)
      __local_fx_id_setter = lambda do |name, __i|
        __local_namespace[name] = __i
        __local_fxml_controller.instance_variable_set(("@#{name}").to_sym, __i)
      end

build(Java::JavafxSceneLayout::BorderPane) do
 __local_jruby_ext[:on_root_set].call(self) if __local_jruby_ext[:on_root_set]
 setTop(build(Java::JavafxSceneControl::ToolBar) do
  getItems.add(build(Java::JavafxSceneControl::Button) do
   setId("layer1_button")
   __local_fx_id_setter.call("layer1_button", self)
   setMnemonicParsing(false)
   setText("Layer 1")
  end)
  getItems.add(build(Java::JavafxSceneControl::Button) do
   setId("layer2_button")
   __local_fx_id_setter.call("layer2_button", self)
   setMnemonicParsing(false)
   setText("Layer 2")
  end)
  getItems.add(build(Java::JavafxSceneControl::Button) do
   setId("layer3_button")
   __local_fx_id_setter.call("layer3_button", self)
   setMnemonicParsing(false)
   setText("Layer 3")
  end)
  setPrefHeight(40.0)
  setPrefWidth(200.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setBottom(build(Java::JavafxSceneControl::Label) do
  setText("Label")
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setLeft(build(Java::JavafxSceneControl::ScrollPane) do
  setContent(build(Java::JavafxSceneLayout::GridPane) do
   setId("tileset_grid_pane")
   __local_fx_id_setter.call("tileset_grid_pane", self)
   getColumnConstraints.add(build(Java::JavafxSceneLayout::ColumnConstraints) do
    setHgrow(Java::javafx::scene::layout::Priority::SOMETIMES)
    setMinWidth(10.0)
    setPrefWidth(100.0)
   end)
   getRowConstraints.add(build(Java::JavafxSceneLayout::RowConstraints) do
    setMinHeight(10.0)
    setPrefHeight(30.0)
    setVgrow(Java::javafx::scene::layout::Priority::SOMETIMES)
   end)
   setGridLinesVisible(true)
   setMinWidth(256.0)
  end)
  setMaxWidth(-Infinity)
  setMinWidth(-Infinity)
  setPrefHeight(200.0)
  setPrefViewportWidth(256.0)
  setPrefWidth(274.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setCenter(build(Java::JavafxSceneControl::ScrollPane) do
  setContent(build(Java::JavafxSceneLayout::StackPane) do
   setId("map_stack_pane")
   __local_fx_id_setter.call("map_stack_pane", self)
   setPrefHeight(150.0)
   setPrefWidth(200.0)
  end)
  setPrefHeight(200.0)
  setPrefWidth(200.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setMaxHeight(-Infinity)
 setMaxWidth(-Infinity)
 setMinHeight(-Infinity)
 setMinWidth(-Infinity)
 setPrefHeight(400.0)
 setPrefWidth(600.0)
end
    end

      def hash
        "946e9357b5600c1fec01fbf200156c4e83f27174"
      end
      def compiled?
        true
      end
    end
  end
end
