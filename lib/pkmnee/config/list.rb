
class PKMNEE::Config::List < PKMNEE::Config::Setting

	attr_accessor :options

	def initialize(args)
		@options = args[:options]
		super
	end
end
