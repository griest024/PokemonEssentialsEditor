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

$plugins = {}
$project = '../Pokemon Virginia'

#everything in these directories will be included
require_rel './lib' , './plugins'

$icon = JavaFX::Image.new("/res/img/pkball.gif")

class PKMNEEditorApp < JRubyFX::Application

	def start(stage)
		with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
			fxml Editor
			setX(50)
			setY(30)
			icons.add($icon)
			setMaximized(true)
			show
		end
		@@window = stage.get_scene.get_window
	end

	def stop
		super
		puts "\n********************************************************************************"
	end

	def self.get_main_window
		@@window
	end
end

PKMNEEditorApp.launch
