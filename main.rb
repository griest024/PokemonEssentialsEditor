#!/usr/bin/ruby

require 'java'
require 'jrubyfx'
require 'require_all'


puts "\n**********************Pokemon*Essentials*Editor*********************************"


#make program output in real time so errors visible in VR.
STDOUT.sync = true
STDERR.sync = true

fxml_root(File.dirname(__FILE__) + '/layout')
resource_root(:images, File.join(File.dirname(__FILE__), "res", "img"), "res/img")

$plugins = {}
$project = '../Pokemon-Virginia'


#everything in these directories will be included
require_rel './lib' , './plugins'

class PKMNEEditorApp < JRubyFX::Application

	def start(stage)
		with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
			fxml Editor
			icons.add(image(resource_url(:images, "pokeball.png").to_s))
			setX(50)
			setY(30)
			show
		end
		@@window = stage.get_scene.get_window
	end

	def stop
		super
		puts "********************************************************************************\n\n"
	end

	def self.get_main_window
		@@window
	end
end

PKMNEEditorApp.launch
