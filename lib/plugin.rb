module PKMNEE::Plugin

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
		
		class_attr_accessor :id
		class_attr_accessor :instances, []
		class_attr_accessor :editors, {}
		class_attr_accessor :handler, DataHandler.new
		class_attr_accessor :instance_params 

		class << self

			def inherited(subclass)
				class << subclass
					attr_accessor :id, :instances, :editors, :handler, :instance_params
					def new
						
					end
					
					def init
						@instances = []
						@editors = {}
						@handler = DataHandler.new
					end

					def name
						raise NotImplementedError.new("You must override self.name")
					end

					def author
						raise NotImplementedError.new("You must override self.author")
					end

					def canHandle?(type)
						@handler.canHandle?(type)
					end

					def canOpen?(type)
						canHandle?(type)
					end

					# An image preview of your app, probably a screenshot of you testing it
					def preview
						
					end

					# returns a short description of your plugin
					def description
						"Author has not added a description. You're on your own."
					end

					#type: the type of instance to get
					#*controller_args: optional args to pass to instance
					def getInstance(type, *controller_args)
						instances << ret = editors[type].new(*controller_args)
						ret
					end

					def to_s
						name
					end

					# Needed so JavaFX can convert this object to a String
					def toString
						to_s
					end
				end
				PKMNEE::Main.declare_plugin(subclass)
			end

			

			# returns the default configuration screen
			# def config
			# 	JavaFX::Label.new("This plugin has no configurable options.")
			# end

		end	
	end

	# Class that holds the configuration for opening an instance of your plugin
	# 
	# class Parameters
	# 	include JRubyFX::Displayable

	# 	class Setting
	# 		include JRubyFX::Displayable

	# 		class List < Setting

	# 			class StringConverter < JavaFX::StringConverter

	# 				private_attr_accessor :options

	# 				def initialize(options_hash)
	# 					super()
	# 					options= options_hash
	# 				end
					
	# 				def toString(obj)
	# 					options[obj]
	# 				end

	# 				def fromString(str)
	# 					options.key(str)
	# 				end
	# 			end

	# 			private_attr_accessor :options, :name, :select

	# 			# literal - keys are the internal symbols that your plugin recognizes, values 
	# 			# 	are the string that contains readable representation of the option
	# 			def initialize(setting_name, literal = {})
	# 				typeCheck(literal => Hash)
	# 				options = literal
	# 				name= setting_name
	# 				select= JavaFX::ComboBox.new(JavaFX::FXCollections.observableArrayList(options.keys))
	# 				select.setConverter(StringConverter.new(options))
	# 				ctrl= JavaFX::VBox.new(JavaFX::Label.new(setting_name), select)
	# 			end

	# 			def addOption(option, display_string)
	# 				typeCheck(display_string => String)
	# 				options << option
	# 				display_strings << display_string
	# 				updateControl
	# 			end

	# 			def add(option, display_string)
	# 				addOption(option, display_string)
	# 			end

	# 			def get
	# 				p ctrl.getSelectionModel.getSelectedItem
	# 			end

	# 			def set(literal = {})
	# 				typeCheck(literal => Hash)
	# 				options= literal
	# 				updateControl
	# 			end

	# 			def updateControl
	# 				select.getItems.setAll(options.keys)
	# 			end
				
	# 		end

	# 		class Edit < Setting

	# 			private_attr_accessor :field, :edit

	# 			def initialize(name, default = nil)
	# 				field= default
	# 			end
				
	# 			def get
	# 				edit.getText
	# 			end
	# 		end

	# 		class Data < Setting

	# 			def initialize(name, *datatypes)
					
	# 			end
	# 		end

	# 		class Boolean < Setting
	# 			def initialize(name, default = false)
					
	# 			end
				
				
	# 		end

	# 		$setting_types = {:list => List, :edit => Edit, :data => Data, :bool => Boolean}

	# 		def initialize
				
	# 		end

	# 		def self.get(type, name, arg)
	# 			$setting_types[type].new(name, arg)
	# 		end
	# 	end

	# 	private_attr_accessor :settings

	# 	def initialize(literal = {})
	# 		typeCheck(literal => Hash)
	# 		settings= literal
	# 	end

	# 	# adds a configurable setting
	# 	# types: :list a choicebox containing the list of options
	# 	#        :files a list of project files that your plugin can handle
	# 	#        :edit a textfield where the user enters a string
	# 	# settings will be returned from args in the order you add them
	# 	def add_setting(type, name, *options)
	# 		@settings[instance] << set = SettingControl.new(name, type, *options)
	# 		@settings[instance][0].getChildren.add(set)
	# 	end

	# 	# returns the selected type of instance to open, will pass to get_instance
	# 	def type
	# 		getSelectionModel.getSelectedItem.getText
	# 	end

	# 	# returns the configured args to pass to controller, will pass to get_instance
	# 	def args
	# 		ans = []
	# 		@settings[type].each do |e|
	# 			ans << e.get if e.is_a?(Setting)
	# 		end
	# 		ans
	# 	end
	# end

	

	# specifies which types a plugin can open
	class DataHandler

		attr_accessor :types

		# define helper methods for handling data types
		$data_types.each_value { |e| define_method(e) { addHandle(e) } }

		def initialize(*types)
			types = []
			addHandle(*types)
		end

		def handleList
			types
		end

		# returns true if this handler can handle the specified data type
		# can take either a :symbol or a Class
		def canHandle?(type)
			if type.is_a?(Class)
				return types.include?($data_types[type])
			elsif type.is_a?(Symbol)	
				types.include?(type)
			else
				puts "Warning: Pass DataHandler#canHandle? a symbol or Class. Read the docs you fool."
			end
		end

		# specifies that the plugin can handle files of type
		def addHandle(*type)
			type.each { |e| types << e }
			types
		end

		# def scripts
		# 	addHandle(:Scripts)
		# 	self
		# end

		# def maps
		# 	addHandle(:Maps)
		# 	self
		# end

		# def skills
		# 	addHandle(:Skills)
		# 	self
		# end

		# def states
		# 	addHandle(:States)
		# 	self
		# end

		# def system
		# 	addHandle(:System)
		# 	self
		# end

		# def tilesets
		# 	addHandle(:Tilesets)
		# 	self
		# end

		# def troops
		# 	addHandle(:Troops)
		# 	self
		# end

		# def weapons
		# 	addHandle(:Weapons)
		# 	self
		# end

		# def animations
		# 	addHandle(:Animations)
		# 	self
		# end

		# def actors
		# 	addHandle(:Actors)
		# 	self
		# end

		# def armors
		# 	addHandle(:Armors)
		# 	self
		# end

		# def classes
		# 	addHandle(:Classes)
		# 	self
		# end

		# def common_events
		# 	addHandle(:CommonEvents)
		# 	self
		# end

		# def constants
		# 	addHandle(:Constants)
		# 	self
		# end

		# def enemies
		# 	addHandle(:Enemies)
		# 	self
		# end

		# def items
		# 	addHandle(:Items)
		# 	self
		# end
	end
end