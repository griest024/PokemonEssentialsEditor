# e99a7ca673c2d73192ebe885ff2206e3d62cb82f encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2016-07-01 15:46:55 -0400 for C:/Users/Peter/PokemonEssentialsEditor/res/fxml/editor-map.fxml
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

with(__local_fxml_controller) do
 setId("border_pane")
 __local_fx_id_setter.call("border_pane", self)
 setTop(build(Java::JavafxSceneControl::ToolBar) do
  setId("toolbar")
  __local_fx_id_setter.call("toolbar", self)
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
  getItems.add(build(Java::JavafxSceneControl::Separator) do
   setPadding(build(FxmlBuilderBuilder, {"left"=>"5.0", "right"=>"5.0"}, Java::JavafxGeometry::Insets) do
   end)
   setOrientation(Java::javafx::geometry::Orientation::VERTICAL)
   setPrefHeight(0.0)
   setPrefWidth(0.0)
  end)
  getItems.add(build(Java::JavafxSceneControl::ToggleButton) do
   setId("layer1_button")
   __local_fx_id_setter.call("layer1_button", self)
   setMnemonicParsing(false)
   setText("Layer 1")
  end)
  getItems.add(build(Java::JavafxSceneControl::ToggleButton) do
   setId("layer2_button")
   __local_fx_id_setter.call("layer2_button", self)
   setMnemonicParsing(false)
   setText("Layer 2")
  end)
  getItems.add(build(Java::JavafxSceneControl::ToggleButton) do
   setId("layer3_button")
   __local_fx_id_setter.call("layer3_button", self)
   setMnemonicParsing(false)
   setText("Layer 3")
  end)
  setPrefHeight(40.0)
  setPrefWidth(200.0)
 end)
 setBottom(build(Java::JavafxSceneControl::Label) do
  setId("info")
  __local_fx_id_setter.call("info", self)
  setText("Label")
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setCenter(build(Java::JavafxSceneControl::ScrollPane) do
  setId("map_scroll_pane")
  __local_fx_id_setter.call("map_scroll_pane", self)
  setPannable(true)
  setPrefHeight(200.0)
  setPrefWidth(200.0)
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
 setFocusTraversable(true)
 setMaxHeight(-Infinity)
 setMaxWidth(-Infinity)
 setMinHeight(-Infinity)
 setMinWidth(-Infinity)
 setPrefHeight(800.0)
 setPrefWidth(1280.0)
end
    end

      def hash
        "e99a7ca673c2d73192ebe885ff2206e3d62cb82f"
      end
      def compiled?
        true
      end
    end
  end
end
