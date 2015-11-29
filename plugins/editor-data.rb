 #    Copyright (C) 2015 - Peter Lauck (griest)

 #    This program is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU General Public License as published by
 #    the Free Software Foundation, either version 3 of the License, or
 #    (at your option) any later version.

 #    This program is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU General Public License for more details.

 #    You should have received a copy of the GNU General Public License
 #    along with this program.  If not, see <http://www.gnu.org/licenses/>.

require 'yaml'

module Plugin
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
				PKMNEE::DataTree.new(loadYAML("Map082"), @data_tree_view)
			end

			def get_node(fx_id)
				instance_variable_set("@" + fx_id.to_s, @scene.lookup("##{fx_id}"))
			end		
		end

	end
end

