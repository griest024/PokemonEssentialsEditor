
class PKMNEE::Config::Setting

	attr_accessor :id, :name, :value, :default

	def initialize(args)
		@id = args[:id]
		@name = args[:name]
		@default = args[:default]
		reset
	end

	def resetValue
		@value = @default.clone
	end

	def reset
		resetValue
	end
	
end
