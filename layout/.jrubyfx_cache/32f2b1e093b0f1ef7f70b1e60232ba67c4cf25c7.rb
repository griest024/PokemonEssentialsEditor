# ad3b23ec970fa27bb934763c3d48f19c702f7bf8 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2015-05-21 15:28:50 -0400 for /home/griest/pkmn-editor/PokemonEssentialsEditor/layout/editor-main.fxml
########################### DO NOT MODIFY THIS FILE ###########################

module JRubyFX
  module GeneratedAssets
    class AOT32f2b1e093b0f1ef7f70b1e60232ba67c4cf25c7
      include JRubyFX
          def __build_via_jit(__local_fxml_controller, __local_namespace, __local_jruby_ext)
      __local_fx_id_setter = lambda do |name, __i|
        __local_namespace[name] = __i
        __local_fxml_controller.instance_variable_set(("@#{name}").to_sym, __i)
      end

build(Java::JavafxSceneLayout::VBox) do
 __local_jruby_ext[:on_root_set].call(self) if __local_jruby_ext[:on_root_set]
 getChildren.add(build(Java::JavafxSceneControl::MenuBar) do
  getMenus.add(build(Java::JavafxSceneControl::Menu) do
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("New")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Open…")
   end)
   getItems.add(build(Java::JavafxSceneControl::Menu) do
    setMnemonicParsing(false)
    setText("Open Recent")
   end)
   getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
    setMnemonicParsing(false)
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Close")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Save")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Save As…")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Revert")
   end)
   getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
    setMnemonicParsing(false)
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Preferences…")
   end)
   getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
    setMnemonicParsing(false)
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Quit")
   end)
   setMnemonicParsing(false)
   setText("File")
  end)
  getMenus.add(build(Java::JavafxSceneControl::Menu) do
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Undo")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Redo")
   end)
   getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
    setMnemonicParsing(false)
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Cut")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Copy")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Paste")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Delete")
   end)
   getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
    setMnemonicParsing(false)
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Select All")
   end)
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("Unselect All")
   end)
   setMnemonicParsing(false)
   setText("Edit")
  end)
  getMenus.add(build(Java::JavafxSceneControl::Menu) do
   getItems.add(build(Java::JavafxSceneControl::MenuItem) do
    setMnemonicParsing(false)
    setText("About MyHelloApp")
   end)
   setMnemonicParsing(false)
   setText("Help")
  end)
  Java::JavafxSceneLayout::VBox.setVgrow(self, Java::javafx::scene::layout::Priority::NEVER)
 end)
 getChildren.add(build(Java::JavafxSceneControl::ComboBox) do
  setId("plugin_select")
  __local_fx_id_setter.call("plugin_select", self)
  Java::JavafxSceneLayout::VBox.setMargin(self, build(FxmlBuilderBuilder, {"bottom"=>"10.0", "left"=>"10.0", "right"=>"10.0", "top"=>"10.0"}, Java::JavafxGeometry::Insets) do
  end)
  setPrefHeight(25.0)
  setPrefWidth(224.0)
  setPromptText("Choose your plugin!")
  setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "open_plugin"))
 end)
 setPrefHeight(400.0)
 setPrefWidth(640.0)
end
    end

      def hash
        "ad3b23ec970fa27bb934763c3d48f19c702f7bf8"
      end
      def compiled?
        true
      end
    end
  end
end
