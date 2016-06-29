
class PKMNEE::Config::Setting

	attr_accessor :id, :name, :value

	def initialize(args)
		@id = args[:id].to_sym
		@name = args[:name].to_s
	end	
end
