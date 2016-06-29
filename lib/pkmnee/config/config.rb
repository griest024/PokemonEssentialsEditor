
class PKMNEE::Config

	require_relative 'setting'
	require_relative 'list'
	require_relative 'edit'
	require_relative 'boolean'

	TYPES = {:list => List, :edit => Edit, :bool => Boolean, :path => Path}

	attr_accessor :settings

	def initialize(settings)
		@settings = {}
		settings.each do |type, args|
			sett = TYPES[type].new(args)
			@settings[sett.id] = sett
			instance_variable_set "@#{sett.id}".to_sym, sett
			define_singleton_method(sett.id) { instance_variable_get("@#{sett.id}".to_sym).value } # define setting getter
			define_singleton_method("#{sett.id}=".to_sym) { |value| instance_variable_get("@#{sett.id}".to_sym).value = value } # define setting setter
		end
	end

	def to_yaml
		hash = {}
		@settings.each { |k, v| hash[k] = v.value }
		hash.to_yaml
	end

	def saveFile
		File.open(PKMNEE::Main.config.config_dir, "w") { |file| file.write to_yaml }
	end
end
