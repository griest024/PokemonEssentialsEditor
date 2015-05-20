#!/usr/bin/ruby

require 'java'
require 'jrubyfx'
require 'require_all'


#make program output in real time so errors are visible
STDOUT.sync = true
STDERR.sync = true

$plugins = {}
$project = '../Pokemon-Virginia'

def add_plugin(plugin_name, plugin_class)
	$plugins[plugin_name] = plugin_class
end

class PKMNEEditorApp < JRubyFX::Application


	
end

#everything in these directories will be included
#require_rel './plugins' , './lib'



#Editor.new($plugins)



