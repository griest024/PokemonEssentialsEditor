
module griest

	module RawDataViewer
		
		class RawDataController < JavaFX::AnchorPane
			include Controller

			loadFXML 'editor-data.fxml'

			def initialize()
				PKMNEE::DataTree.new(loadYAML("Map082"), @data_tree_view)
			end
		end
	end
end