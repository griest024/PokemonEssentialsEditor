module PKMNEE::Util

	class DataWrapper

		attr_accessor :path, :id
		attr_reader :class

		def initialize(klass, path)
			@class = klass
			@path = path
			@id = File.basename(path, ".*").to_sym
		end
		
		def load
			Psych.load_file(@path)
		end

		def get
			load
		end
	end

	class TileImageWrapper < DataWrapper

		def initialize(path)
			@path = path
			@class = PKMNEE::Util::TileImageWrapper
			@id = File.basename(path, ".*")
		end
		
		def load
			JavaFX::Image.new(resource_url(:tiles, path).to_s)
		end
	end
end