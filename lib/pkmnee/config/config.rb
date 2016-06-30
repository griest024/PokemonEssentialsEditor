
class PKMNEE::Config

	require_relative 'setting'
	require_relative 'list'
	require_relative 'edit'
	require_relative 'boolean'
	require_relative 'path'

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

	def to_hash
		hash = {}
		@settings.each { |k, v| hash[k] = v.value }
		hash
	end

	def to_h
		to_hash
	end

	def to_yaml
		to_hash.to_yaml
	end

	def loadHash(hash)
		hash.each { |k, v| @settings[k].value = v if @settings[k] }
	end

	def loadFile(path)
		loadHash Psych.load_file(path)
	end

	def saveFile(path)
		File.open(path, "w") { |file| file.write to_yaml }
	end
end
