
require_relative 'data_handler'
require_relative 'base'

module PKMNEE::Plugin

	# class Screen < JavaFX::Stage

	# 	attr_accessor :root

	# 	def initialize(root, *properties)
	# 		if root.is_a?(JavaFX::Parent)
	# 			root= root
	# 		else
	# 			raise ArgumentError.new("Screen needs a JavaFX Parent as a root")
	# 		end
	# 		inflateContent if @root
	# 		setProperties(*properties)
	# 	end

	# 	def setProperties(*args)
	# 		args[0].each_pair { |k,v| send((k.to_s + "=").to_sym, v) }
	# 	end
		
	# 	def inflateContent
	# 		@scene = JavaFX::Scene.new(@root)
	# 		setScene(@scene)
	# 	end
		
	# end

	

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
end
