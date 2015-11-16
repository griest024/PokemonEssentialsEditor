module Plugin

	module Controller

		def loadFXML(filename)
			loader = JavaFX::FXMLLoader.new(self.getClass.getResource(self.layoutDir + filename + '.fxml'))
			loader.setRoot(self)
			loader.setController(self)
			begin
				loader.load
			rescue JavaFX::LoadException
				puts(e.getMessage + " Failed to load FXML")
			end

		end
	end

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
		
		attr_accessor(:id)
		attr_reader(:instances, :types, :handler)

		def initialize
			@types = {}
			@instances = []
			@handler = FileHandler.new
		end

		class << self

			def inherited(subclass)
				PKMNEE::Main.declarePlugin(subclass)
			end

			def name
				raise NotImplementedError.new("You must override self.name")
			end

			def author
				raise NotImplementedError.new("You must override self.author")
			end

		end



		def canHandle?(type)
			@handler.canHandle?(type)
		end

		# An image preview of your app, probably a screenshot of you using it
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
		def getInstance(type, *controller_args)
			instances << ret = @types[type].new(*controller_args)
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
		class Config

			def initialize(literal)
				@settings = literal
				
			end

			# adds a configurable setting
			# types: :list a choicebox containing the list of options
			#        :files a list of project files that your plugin can handle
			#        :edit a textfield where the user enters a string
			# instance: the type of instance that the setting will be added to
			# settings will be returned from args in the order you add them
			def addSetting(instance, name, type, *options)
				@settings[instance] << set = SettingControl.new(name, type, *options)
				@settings[instance][0].getChildren.add(set)
			end

			# returns the selected type of instance to open, will pass to getInstance
			def type
				getSelectionModel.getSelectedItem.getText
			end

			# returns the configured args to pass to controller, will pass to getInstance
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

		

		# specifies which files a plugin can open, configure this class BEFORE Config
		class FileHandler

			def initialize(*types)
				@types = []
				addHandle(*types)
			end

			def handleList
				@types
			end

			def canHandle?(type)
				@types.include?(type)
			end

			# specifies that the plugin can handle files of type
			def addHandle(*type)
				type.each { |e| @types << e }
				@types
			end

			def scripts
				addHandle(:Scripts)
				self
			end

			def maps
				addHandle(:Maps)
				self
			end

			def skills
				addHandle(:Skills)
				self
			end

			def states
				addHandle(:States)
				self
			end

			def system
				addHandle(:System)
				self
			end

			def tilesets
				addHandle(:Tilesets)
				self
			end

			def troops
				addHandle(:Troops)
				self
			end

			def weapons
				addHandle(:Weapons)
				self
			end

			def animations
				addHandle(:Animations)
				self
			end

			def actors
				addHandle(:Actors)
				self
			end

			def armors
				addHandle(:Armors)
				self
			end

			def classes
				addHandle(:Classes)
				self
			end

			def common_events
				addHandle(:CommonEvents)
				self
			end

			def constants
				addHandle(:Constants)
				self
			end

			def enemies
				addHandle(:Enemies)
				self
			end

			def items
				addHandle(:Items)
				self
			end
		end
	end
end