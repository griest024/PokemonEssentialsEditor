# 487146da705d936255af3f115e819796ceec26fb encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2015-05-28 14:33:43 -0400 for /home/griest/pkmn-editor/PokemonEssentialsEditor/layout/editor-map.fxml
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
  getItems.add(build(Java::JavafxSceneControl::Slider) do
   setId("map_scale_slider")
   __local_fx_id_setter.call("map_scale_slider", self)
   setBlockIncrement(0.25)
   setMajorTickUnit(0.25)
   setMax(1.0)
   setMin(0.25)
   setMinorTickCount(0)
   setShowTickLabels(true)
   setShowTickMarks(true)
   setSnapToTicks(true)
   setValue(1.0)
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
  setId("tileset_scroll_pane")
  __local_fx_id_setter.call("tileset_scroll_pane", self)
  setMaxWidth(-Infinity)
  setMinWidth(-Infinity)
  setPrefHeight(200.0)
  setPrefViewportWidth(256.0)
  setPrefWidth(274.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setCenter(build(Java::JavafxSceneControl::ScrollPane) do
  setId("map_scroll_pane")
  __local_fx_id_setter.call("map_scroll_pane", self)
  setContent(build(Java::JavafxScene::Group) do
   getChildren.add(build(Java::JavafxSceneLayout::StackPane) do
    setId("map_stack_pane")
    __local_fx_id_setter.call("map_stack_pane", self)
    setAlignment(Java::javafx::geometry::Pos::TOP_LEFT)
    setPrefHeight(150.0)
    setPrefWidth(200.0)
   end)
  end)
  setPannable(true)
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
        "487146da705d936255af3f115e819796ceec26fb"
      end
      def compiled?
        true
      end
    end
  end
end
