# 3941ecfbce17b14a53ae28b8731aa059aeb5af40 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2016-07-21 15:03:53 +0800 for C:/Users/Peter/PokemonEssentialsEditor/res/fxml/editor-main.fxml
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

build(Java::JavafxSceneLayout::BorderPane) do
 __local_jruby_ext[:on_root_set].call(self) if __local_jruby_ext[:on_root_set]
 setLeft(build(Java::JavafxSceneLayout::HBox) do
  setId("data_hbox")
  __local_fx_id_setter.call("data_hbox", self)
  setPrefHeight(100.0)
  setPrefWidth(200.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setCenter(build(Java::JavafxSceneControl::TabPane) do
  setId("tab_pane")
  __local_fx_id_setter.call("tab_pane", self)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setTop(build(Java::JavafxSceneControl::ToolBar) do
  getItems.add(build(Java::JavafxSceneControl::MenuBar) do
   getMenus.add(build(Java::JavafxSceneControl::Menu) do
    setId("menu_file")
    __local_fx_id_setter.call("menu_file", self)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_new")
     __local_fx_id_setter.call("menu_file_new", self)
     setMnemonicParsing(false)
     setText("New")
     setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "menuNew"))
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_open")
     __local_fx_id_setter.call("menu_file_open", self)
     setAccelerator(build(FxmlBuilderBuilder, {"alt"=>"UP", "code"=>"O", "control"=>"DOWN", "meta"=>"UP", "shift"=>"UP", "shortcut"=>"UP"}, Java::JavafxSceneInput::KeyCodeCombination) do
     end)
     setMnemonicParsing(false)
     setText("Open\u2026")
     setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "openDialog"))
    end)
    getItems.add(build(Java::JavafxSceneControl::Menu) do
     setId("menu_file_open_recent")
     __local_fx_id_setter.call("menu_file_open_recent", self)
     setMnemonicParsing(false)
     setText("Open Recent")
    end)
    getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
     setMnemonicParsing(false)
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_save")
     __local_fx_id_setter.call("menu_file_save", self)
     setAccelerator(build(FxmlBuilderBuilder, {"alt"=>"UP", "code"=>"S", "control"=>"DOWN", "meta"=>"UP", "shift"=>"UP", "shortcut"=>"UP"}, Java::JavafxSceneInput::KeyCodeCombination) do
     end)
     setMnemonicParsing(false)
     setText("Save")
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_save_all")
     __local_fx_id_setter.call("menu_file_save_all", self)
     setAccelerator(build(FxmlBuilderBuilder, {"alt"=>"UP", "code"=>"S", "control"=>"DOWN", "meta"=>"UP", "shift"=>"DOWN", "shortcut"=>"UP"}, Java::JavafxSceneInput::KeyCodeCombination) do
     end)
     setMnemonicParsing(false)
     setText("Save All")
     setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "saveAll"))
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_revert")
     __local_fx_id_setter.call("menu_file_revert", self)
     setAccelerator(build(FxmlBuilderBuilder, {"alt"=>"UP", "code"=>"Z", "control"=>"DOWN", "meta"=>"UP", "shift"=>"UP", "shortcut"=>"UP"}, Java::JavafxSceneInput::KeyCodeCombination) do
     end)
     setMnemonicParsing(false)
     setText("Revert")
    end)
    getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
     setMnemonicParsing(false)
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setId("menu_file_settings")
     __local_fx_id_setter.call("menu_file_settings", self)
     setMnemonicParsing(false)
     setText("Settings")
    end)
    getItems.add(build(Java::JavafxSceneControl::SeparatorMenuItem) do
     setMnemonicParsing(false)
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
  end)
  getItems.add(build(Java::JavafxSceneControl::Button) do
   setId("plugin_select")
   __local_fx_id_setter.call("plugin_select", self)
   setMnemonicParsing(false)
   setText("Plugin selection")
   setOnAction(EventHandlerWrapper.new(__local_fxml_controller, "openPluginSelect"))
  end)
  setPrefHeight(40.0)
  setPrefWidth(200.0)
  Java::JavafxSceneLayout::BorderPane.setAlignment(self, Java::javafx::geometry::Pos::CENTER)
 end)
 setFocusTraversable(true)
 setPrefHeight(616.0)
 setPrefWidth(942.0)
end
    end

      def hash
        "3941ecfbce17b14a53ae28b8731aa059aeb5af40"
      end
      def compiled?
        true
      end
    end
  end
end
