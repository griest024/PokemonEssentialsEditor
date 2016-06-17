
module PKMNEE::Plugin

	# specifies which types a plugin can open
	class DataHandler

		attr_accessor :handles
		attr_accessor :universal

		# define helper methods for handling data types
		$data_classes.keys.each { |e| self.define_method(e.to_sym) { |controller| addHandle(controller, e.to_sym) } }

		def initialize(default = nil)
			@universal = false
			@handles = {nil: default}
			@handles.default = default
		end

		def default=(value)
			@handles[:nil] = value
		end

		def getController(data)
			@handles[data.class.to_sym]
		end

		def handle(data)
			getController(data)
		end

		def universal?
			@universal
		end

		def handleAll
			@universal = true
			self
		end

		def get(data)
			getController(data)
		end

		def handleList
			@handles.keys
		end

		# returns true if this handler can handle the specified data type
		# can take either a Symbol or a Class
		def canHandle?(data)
			@handles.keys.include?(data.class.to_sym) || @universal
		end

		# specifies that the plugin can handle files of type
		def addHandle(controller, *types)
			types.each { |e| @handles[e.to_sym] = controller }
			self
		end

		def set(controller, *types)
			addHandle(controller, *types)
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