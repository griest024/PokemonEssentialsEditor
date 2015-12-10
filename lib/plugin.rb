module Plugin

	class Screen < JavaFX::Stage

		attr_accessor(:root)

		def initialize(root, *properties)
			if root.is_a?(JavaFX::Parent)
				root= root
			else
				raise ArgumentError.new("Screen needs a JavaFX Parent as a root")
			end
			inflateContent if @root
			setProperties(*properties)
		end

		def setProperties(*args)
			args[0].each_pair { |k,v| send((k.to_s + "=").to_sym, v) }
		end
		
		def inflateContent
			@scene = JavaFX::Scene.new(@root)
			setScene(@scene)
		end
		
	end

	class Base
		
		attr_accessor(:id, :instances,  :editors, :handler, :instance_params)

		def initialize
			@editors = {}
			@instances = []
			@handler = DataHandler.new
		end

		class << self

			def inherited(subclass)
				PKMNEE::Main.declare_plugin(subclass)
			end

			def name
				raise NotImplementedError.new("You must override self.name")
			end

			def author
				raise NotImplementedError.new("You must override self.author")
			end

		end

		def can_handle?(type)
			@handler.can_handle?(type)
		end

		# An image preview of your app, probably a screenshot of you testing it
		def preview
			
		end

		# returns a short description of your plugin
		def description
			"Author has not added a description. You're on your own."
		end

		# returns the default configuration screen
		def config
			JavaFX::Label.new("This plugin has no configurable options.")
		end

		#type: the type of instance to get
		#*controller_args: optional args to pass to instance
		def get_instance(type, *controller_args)
			instances << ret = editors[type].new(*controller_args)
			ret
		end

		def to_s
			self.class.name
		end

		# Needed so JavaFX can convert this object to a String
		def toString
			to_s
		end

		# Class that holds the configuration for opening an instance of your plugin
		# 
		class Parameters < JavaFX::TabPane

			def initialize(plugin)
				@settings = {}
				@instances = plugin.types.keys
				@instances.each do |e|
					tp = JavaFX::TilePane.new
					@settings[e] = [tp]
					getTabs.add(Tab.new(e, tp))
				end
				# @anchor = JavaFX::AnchorPane.new
				# @list_view = JavaFX::ListView.new(JavaFX::FXCollections.observableArrayList(@instances))
				# @list_view.getSelectionModel.setSelectionMode(JavaFX::SelectionMode.SINGLE)
				# @list_view.getSelectionModel.selectedItemProperty.java_send( \
				# 	:addListener, [javafx.beans.value.ChangeListener], lambda do |ov,old,new|
				# 		@anchor.getChildren.setAll(@settings[new][0])
				# 	end)
				# getTabs.addAll(@anchor)
			end

			# adds a configurable setting
			# types: :list a choicebox containing the list of options
			#        :files a list of project files that your plugin can handle
			#        :edit a textfield where the user enters a string
			# instance: the type of instance that the setting will be added to
			# settings will be returned from args in the order you add them
			def add_setting(instance, name, type, *options)
				@settings[instance] << set = SettingControl.new(name, type, *options)
				@settings[instance][0].getChildren.add(set)
			end

			# returns the selected type of instance to open, will pass to get_instance
			def type
				getSelectionModel.getSelectedItem.getText
			end

			# returns the configured args to pass to controller, will pass to get_instance
			def args
				ans = []
				@settings[type].each do |e|
					ans << e.get if e.is_a?(SettingControl)
				end
				ans
			end

			class SettingControl < JavaFX::VBox

				def initialize(name, type, *options)
					case type
					when :list
						@control = JavaFX::ChoiceBox.new(JavaFX::FXCollections.observableArrayList(*options))
					when :edit
						@control = JavaFX::TextField.new
					when :files
						@control = Util::FileComboBox.new
					else
						puts "Not a proper type of control!"
					end
					getChildren.setAll(JavaFX::Label.new(name), @control)
				end
				
				def get
					@control.is_a?(JavaFX::TextField) ? @control.getCharacters.toString : @control.getSelectionModel.getSelectedItem
				end
			
			end
		end

		

		# specifies which types a plugin can open, configure this class BEFORE Config
		class DataHandler

			def initialize(*types)
				@types = []
				add_handle(*types)
			end

			def handle_list
				@types
			end

			def can_handle?(type)
				@types.include?(type)
			end

			# specifies that the plugin can handle files of type
			def add_handle(*type)
				type.each { |e| @types << e }
				@types
			end

			def scripts
				add_handle(:Scripts)
				self
			end

			def maps
				add_handle(:Maps)
				self
			end

			def skills
				add_handle(:Skills)
				self
			end

			def states
				add_handle(:States)
				self
			end

			def system
				add_handle(:System)
				self
			end

			def tilesets
				add_handle(:Tilesets)
				self
			end

			def troops
				add_handle(:Troops)
				self
			end

			def weapons
				add_handle(:Weapons)
				self
			end

			def animations
				add_handle(:Animations)
				self
			end

			def actors
				add_handle(:Actors)
				self
			end

			def armors
				add_handle(:Armors)
				self
			end

			def classes
				add_handle(:Classes)
				self
			end

			def common_events
				add_handle(:CommonEvents)
				self
			end

			def constants
				add_handle(:Constants)
				self
			end

			def enemies
				add_handle(:Enemies)
				self
			end

			def items
				add_handle(:Items)
				self
			end
		end
	end
end