#!/usr/bin/ruby

require 'java'
require 'jrubyfx'
require 'require_all'


puts "\n***************************Pokemon Essentials Editor****************************"


#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

fxml_root(File.dirname(__FILE__) + '/layout')
resource_root(:images, File.join(File.dirname(__FILE__), "res", "img"), "res/img")

$project = '../Pokemon Virginia'

#everything in these directories will be included
require_rel './lib' , './plugins'

$icon = JavaFX::Image.new("/res/img/pkball.gif")

PKMNEE::Main.launch
