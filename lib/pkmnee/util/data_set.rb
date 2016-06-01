
module PKMNEE::Util

	class DataSet
		attr_accessor :data_class
		attr_accessor :data
		
		def initialize(klass, *data)
			@data = {}
			@data_class = klass
			addData(*data)
		end

		def addData(*data)
			data.each { |e| e.is_a?(@data_class) ? @data[e.id] = e : puts("This DataSet can only contain data of class #{@data_class}") }
		end
		
		def class
			@data_class
		end

		def to_sym
			@data_class.to_sym
		end

		def inspect
			"DataSet<#{@data_class}>, size: #{@data.size}"
		end

		def to_s
			@data_class.to_s
		end
	end
end
