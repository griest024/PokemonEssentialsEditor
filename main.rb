#!/usr/bin/ruby

require 'gtk2'
require_relative './lib/rgss'
require 'require_all'

#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

$plugins = {}
$YAMLDir = '../Pokemon-Virginia/src/Data'

def add_plugin(plugin_name, plugin_class)
	$plugins[plugin_name] = plugin_class
end

#everything in these directories will be included
require_rel './plugins'



Editor.new($plugins)



Gtk.main

