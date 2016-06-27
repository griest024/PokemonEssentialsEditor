
class PKMNEE::Config::Edit < PKMNEE::Config::Setting

	attr_accessor :type

	def initialize(args)
		@type = args[:type]
		super
	end
	
end
