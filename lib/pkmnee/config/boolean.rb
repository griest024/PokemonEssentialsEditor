
class PKMNEE::Config::Boolean < PKMNEE::Config::Setting

	def initialize(args)
		args.default = false
		super
	end
end
