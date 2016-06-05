
module PKMNEE::Util

	# no nested DataSets ATM
	# stores paths instead of actual objects to reduce memory overhead
	class DataSet
		attr_accessor :data_class
		attr_accessor :data_files
		attr_accessor :dir
		
		def initialize(klass, dir = "")
			@data_files = {}
			@data_class = (klass.is_a?(Class) ? klass : $data_classes[klass])
			setDir(dir) if dir
		end

		def addData(*data_files)
			data_files.each { |path| path.scan(/(\w*).yaml$/) { |id| @data_files[id[0].to_sym] = path } }
			self
		end

		def setDir(dirname)
			@dir = File.expand_path(dirname)
			addData(*(Dir[@dir + "/*"].select { |e| !File.directory?(e) })) # add files but not subdirectories
		end

		def [](name)
			load(name)
		end

		def load(name)
			name.is_a?(Symbol) ? loadFromID(name) : loadFromPath(name)
		end

		def loadFromID(id)
			Psych.load_file(@data_files[id])
		end

		def loadFromPath(path)
			Psych.load_file(path)
		end
		
		def class
			@data_class
		end

		def to_sym
			@data_class.to_sym
		end

		def inspect
			"DataSet<#{@data_class}>, size: #{@data_files.size}"
		end

		def to_s
			@data_class.to_s
		end
	end
end
