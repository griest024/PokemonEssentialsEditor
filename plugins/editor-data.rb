
require 'yaml'


class RawDataController < Java::javafx.scene.layout.AnchorPane
	include JRubyFX::Controller

	fxml 'editor-data.fxml'

	def initialize()
		PKMNEE::DataTree.new(load_yaml("Map082"), @data_tree_view)
	end

	def get_node(fx_id)
		instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
	end		
end

class RawDataPlugin < PKMNEE::Plugin

	def initialize
		super
		@types[:default] = RawDataController
	end

	class << self

		def name
			"Raw Data Editor"
		end

		def config
			
		end
	end

end

