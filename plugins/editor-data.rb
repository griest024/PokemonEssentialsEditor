
require 'yaml'

module PKMNEE::Plugin
	class RawDataPlugin < Base

		def initialize
			super
			@types[:default] = RawDataController
		end

		class << self

			def name
				"Raw Data Editor"
			end

			def author
				"griest"
			end
		end

		class RawDataController < JavaFX::AnchorPane
			include JRubyFX::Controller

			fxml 'editor-data.fxml'

			def initialize()
				PKMNEE::DataTree.new(load_yaml("Map082"), @data_tree_view)
			end

			def get_node(fx_id)
				instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
			end		
		end

	end
end

