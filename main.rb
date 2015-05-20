#!/usr/bin/ruby

require 'java'
require 'jrubyfx'
require 'require_all'

fxml_root(File.dirname(__FILE__) + "/layout")


#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

$plugins = {}
$project = '../Pokemon-Virginia'

def add_plugin(plugin_name, plugin_class)
	$plugins[plugin_name] = plugin_class
end

class PKMNEEditorApp < JRubyFX::Application

	def start(stage)
		with(stage, title: "Pokemon Essentials Editor", width: 800, height: 600) do
			fxml "editor-main.fxml"
			show
    	end
	end
	
end

#everything in these directories will be included
#require_rel './plugins' , './lib'



PKMNEEditorApp.launch



