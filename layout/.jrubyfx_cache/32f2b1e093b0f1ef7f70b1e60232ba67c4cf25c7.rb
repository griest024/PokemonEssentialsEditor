# 353fc65f77d96f220483ce0ca93f628e58102746 encoding: utf-8
# @@ 1

########################### DO NOT MODIFY THIS FILE ###########################
#       This file was automatically generated by JRubyFX-fxmlloader on        #
# 2016-06-19 08:47:15 -0400 for C:/Users/Peter/PokemonEssentialsEditor/layout/editor-main.fxml
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
 getChildren.add(build(Java::JavafxSceneControl::ToolBar) do
  getItems.add(build(Java::JavafxSceneControl::MenuBar) do
   getMenus.add(build(Java::JavafxSceneControl::Menu) do
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setMnemonicParsing(false)
     setText("New")
    end)
    getItems.add(build(Java::JavafxSceneControl::MenuItem) do
     setMnemonicParsing(false)
     setText("Open\u2026")
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
     setText("Save As\u2026")
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
     setText("Preferences\u2026")
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
 end)
 getChildren.add(build(Java::JavafxSceneControl::SplitPane) do
  setId("splitpane")
  __local_fx_id_setter.call("splitpane", self)
  getItems.add(build(Java::JavafxSceneLayout::HBox) do
   setId("data_hbox")
   __local_fx_id_setter.call("data_hbox", self)
   setPrefHeight(100.0)
   setPrefWidth(200.0)
  end)
  getItems.add(build(Java::JavafxSceneControl::TabPane) do
   setId("tab_pane")
   __local_fx_id_setter.call("tab_pane", self)
  end)
  setDividerPositions(*[0.1])
  setMaxHeight(1.7976931348623157e+308)
  setMaxWidth(1.7976931348623157e+308)
 end)
 setMaxHeight(-Infinity)
 setMaxWidth(-Infinity)
 setMinHeight(-Infinity)
 setMinWidth(-Infinity)
 setPrefHeight(800.0)
 setPrefWidth(1280.0)
end
    end

      def hash
        "353fc65f77d96f220483ce0ca93f628e58102746"
      end
      def compiled?
        true
      end
    end
  end
end
