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

module PKMNEE::Plugin
	class RawData < Base

		class << self

			def init
				@handler = DataHandler.new(RawDataView).handleAll
				@name = "Raw Data"
				@author = "griest"
				@description = "Allows you to view the attributes of all the data associated with your game"
			end

		end

		class RawDataView < JavaFX::VBox

			def initialize(data = nil)
				super()
				# setMinHeight(self.class::USE_PREF_SIZE)
				setMaxHeight(Java::Double::MAX_VALUE)
				# setPrefHeight(1000)
				if data # load a discrete set of data
					getChildren.add(PKMNEE::Control::DataTreeView.new(data))
				else # load everything
					@accordion = JavaFX::Accordion.new
					$data.each do |k,v| 
						@accordion.getPanes.add(JavaFX::TitledPane.new(k.to_s, PKMNEE::Control::DataTreeView.new(v)))
					end
					@accordion.setMaxHeight(Java::Double::MAX_VALUE)
					getChildren.add(@accordion)
				end
			end
		end
	end
end

