
module PKMNEE::Util

	# no nested DataSets ATM
	# stores paths instead of actual objects to reduce memory overhead
	class DataSet
		attr_accessor :data_class
		attr_accessor :data_files
		# attr_accessor :dir
		
		def initialize(klass, *data_files)
			@data_files = {}
			@data_class = (klass.is_a?(Class) ? klass : $data_classes[klass])
			addData(*data_files)
		end

		def addData(*data_files)
			data_files.each { |e| @data_files[e.id] = e }
			self
		end

		def [](id)
			load(id)
		end

		def get(id)
			load(id)
		end

		def load(id)
			@data_files[id].get
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
