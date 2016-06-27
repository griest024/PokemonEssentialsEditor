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


###############################################################################

module PKMNEE

	$data = {}
	$data_classes = {}
	$default_plugins = {}

	class Main < JRubyFX::Application

		@plugins = []

		def start(stage)
			puts "\n***************************Pokemon Essentials Editor****************************\n\n"
			# img = JavaFX::WritableImage.new(32, 32)
			# writer = img.getPixelWriter
			# format = img.getPixelReader.getPixelFormat
			# black = JavaFX::Color::BLACK
			# white = JavaFX::Color::WHITE
			# [[3, 28, black], [1, 30, white], [2, 29, white], [0, 31, black]].each do |e|
			# 	32.times do |x|
			# 		32.times do |y|
			# 			writer.setColor(x, y, e[2]) if x == e[0] || y == e[0] || x == e[1] || y == e[1]
			# 		end
			# 	end
			# end
			# JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(img, nil), "png", Java::File.new("#{$root_dir}/res/test.png"))
			self.class.initPlugins
			# PKMNEE::Import.all
			self.class.loadProjectData
			@stage = stage.setGlobalParent
			with(stage, title: "Pokemon Essentials Editor", width: 300, height: 300) do
				fxml Editor
				setX(50)
				setY(30)
				icons.add($icon)
				setMaximized(true)
				show
			end
		end

		def stop
			super
			puts "\n********************************************************************************"
		end

		class << self

			def loadProjectData
				# gets all data subfolders that contain PKMN data
				Dir["#{$project_dir}/data/*"].select { |dir| File.directory?(dir) && $data_classes.keys.include?(File.basename(dir).to_sym) }.each do |dir|
					type = File.basename(dir).to_sym
					data_set = PKMNEE::Util::DataSet.new($data_classes[type])
					Dir["#{dir}/*.yaml"].each do |file| # populate the data set with all yaml files in directory
						data_set.addData(PKMNEE::Util::DataWrapper.new($data_classes[type], file))
					end
					$data[type] = data_set
				end
			end

			def initPlugins
				@plugins.each { |plugin| plugin.initPlugin }
			end

			def loadPlugins
				@plugins.each_index { |i| @plugins[i].id= i }
			end

			def names
	 			@plugins.map { |plugin| plugin.name }
	 		end

	 		def openInTab(data)
	 			tab = JavaFX::Tab.new
	 			tab.setText "#{defaultPlugin(data).to_s} - #{data.id}"
				tab.setContent open(data).anchor
				$main_tab_pane.getTabs.add tab
				$main_tab_pane.getSelectionModel.select tab
	 		end

	 		def openInWindow(data)
	 			stage = JavaFX::Stage.new
	 			stage.setScene JavaFX::Scene.new(open(data))
	 			stage.setTitle "#{defaultPlugin(data).to_s}: #{data}"
	 			stage.icons.add $icon
	 			stage.setMaximized true
	 			stage.show
	 		end

	 		def defaultPlugin(data)
	 			$default_plugins[data.class.to_sym]
	 		end

	 		def open(data)
				openWith(data, defaultPlugin(data))
	 		end

	 		def openWith(data, plugin)
	 			plugin.new(data)
	 		end

	 		def eachName(&block)
	 			self.names.each(block)
	 		end

	 		def numPlugins
	 			@plugins.size
	 		end

			def declarePlugin(plugin)
				@plugins << plugin
			end

			#DELETE
			def plugins
				@plugins
			end
			#DELETE
		end
	end

	class Editor
		include JRubyFX::Controller

		fxml 'editor-main.fxml'	

		def initialize
			Main.loadPlugins
			$main_tab_pane = @tab_pane # make global so other classes can add tabs
			puts "Plugins loaded: #{Main.names}"
			@data_hbox.getChildren.addAll PKMNEE::Plugin::RawData.new.anchor, JavaFX::Separator.new(JavaFX::Orientation::VERTICAL)
		end

		def openPluginSelect
			stage = JavaFX::Stage.new
			select = PluginSelect.new(@tab_pane, stage) # initialize it up here so @tab_pane is in scope
			with(stage, title: "Plugin Selection", width: 800, height: 600) do
				icons.add($icon)
				layout_scene(800, 600) do
					select
				end
		      show
			end
		end

		class PluginSelect < JavaFX::VBox
			include JRubyFX::Controller

			fxml 'plugin-select.fxml'

			def initialize(tab_pane, stage)
				@tab_pane = tab_pane
				@stage = stage
				@plugin_select_vbox.getChildren.addAll(@author_label = PKMNEE::Control::NamedLabel.new("Author"), @description_label = PKMNEE::Control::NamedLabel.new("Description"))
				@preview_vbox.getChildren.add(@data_label = PKMNEE::Control::NamedLabel.new("Data types this plugin can open"))
				@data_label.setWrapText(true)
				@description_label.setWrapText(true)
				@plugin_list.setItems(JavaFX::FXCollections.observableArrayList(PKMNEE::Main.plugins))
				@plugin_list.getSelectionModel.selectedItemProperty.java_send(:addListener, [javafx.beans.value.ChangeListener], lambda do |ov, old, new|
						plugin = ov.getValue
						@author_label.text = plugin.author
						@description_label.text = plugin.description
						str = ""
						plugin.handler.handleList.each { |type| str += type.to_s } # concatenates the data types from the handler
						@data_label.text = str
						@preview_imageview.setImage(plugin.preview)
					end)
			end

			def openPlugin
				plugin = @plugin_list.getSelectionModel.getSelectedItem
				return unless plugin
				if @window_checkbox.isSelected # open in new window
					stage = JavaFX::Stage.new
					with(stage, title: plugin.to_s, width: 800, height: 600) do
						icons.add($icon)
						setMaximized(true)
						layout_scene(800, 600) do
	           	plugin.new
	       		end
	       		show
					end
				else # open in tab pane
					tab = build(JavaFX::Tab) do
						setText(plugin.to_s)
						setContent(plugin.new)
					end	
					@tab_pane.getTabs.add(tab)
					@tab_pane.getSelectionModel.select(tab)
				end
				@stage.close
			end	
		end
	end
end