require_relative 'setting'

class PKMNEE::Config

	TYPES = {:list => List, :edit => Edit, :bool => Boolean}

	attr_accessor :settings

	def initialize(settings)
		@settings = []
		settings.each { |type, args| @settings << TYPES[type].new args }
	end

end
