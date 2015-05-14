#!/usr/bin/ruby

require 'gtk2'
require 'require_all'

#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true


#everything in these directories will be included
require_rel './plugins'

Editor.new

Gtk.main

