
module PKMNEE::Util

	# no nested DataSets ATM
	class DataSet
		attr_accessor :data_class
		attr_accessor :wrappers
		# attr_accessor :dir
		
		def initialize(klass, *wrappers)
			@wrappers = {}
			@data_class = (klass.is_a?(Class) ? klass : $data_classes[klass])
			addData(*wrappers)
		end

		def addData(*wrappers)
			wrappers.each { |e| @wrappers[e.id] = e }
			self
		end

		def [](id)
			load(id)
		end

		def load(id)
			@wrappers[id].get
		end
		
		def class
			@data_class
		end

		def to_sym
			@data_class.to_sym
		end

		def inspect
			"DataSet<#{@data_class}>, size: #{@wrappers.size}"
		end

		def to_s
			@data_class.to_s
		end
	end
end
