module PKMNEE::Util

	class DataWrapper

		attr_accessor :path, :id

		def initialize(klass, path)
			@path = path.force_encoding("UTF-8")
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
			@path = path.force_encoding("UTF-8")
			@id = File.basename(path, ".*")
		end
		
		def load
			JavaFX::Image.new(resource_url(:tiles, path).to_s)
		end
	end

	class AutotileImageWrapper < TileImageWrapper

		def load
			JavaFX::Image.new(resource_url(:autotiles, path).to_s)
		end
	end
end