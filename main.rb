#!/usr/bin/ruby

require 'java'
require 'jrubyfx'
require 'require_all'


puts "********************************************************************************"

fxml_root(File.dirname(__FILE__) + "/layout")


#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

fxml_root(File.dirname(__FILE__) + '/layout')

$plugins = {}
$project = '../Pokemon-Virginia'


def declare_plugin(plugin_name, plugin_class)
	$plugins[plugin_name] = plugin_class
end


#everything in these directories will be included
require_rel './plugins' , './lib'

class PKMNEEditorApp < JRubyFX::Application

	def start(stage)
		with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
			fxml Editor
			show
		end
	end
end

PKMNEEditorApp.launch
