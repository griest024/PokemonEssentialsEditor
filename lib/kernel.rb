module Kernel

	def simpleType?(data)
		simpleTypes = [Fixnum, String, FalseClass, TrueClass]
		simpleTypes.include?(data.class)
	end

	def simpleType(data)
		simpleType?(data) ? "#{data}" : "#{data.class}, ID: #{data.object_id}"
	end

	def loadYAML(filename)
		parsed = begin
  			YAML::load(File.open("#{$project}/src/Data/#{filename}.yaml"))
		rescue ArgumentError => e
  			puts "Could not parse YAML: #{e.message}"
		end
		parsed
	end

	def set_node_size(node, width, height)
		node.setMinWidth(width)
		node.setMaxWidth(width)
		node.setMinHeight(height)
		node.setMaxHeight(height)
	end

	def caller_puts(*args)
		args.map! { |e| caller[0].to_s + e if e.is_a?(String) }
	end

	# Raises ArgumentError if keys are not of 
	def typeCheck(args = {})
		raise ArgumentError.new("Pass objects and types in as keys and values, respectively.") unless args.is_a?(Hash)
		args.each_pair do |k,v|
			v = [v] unless v.is_a?(Array)
			raise ArgumentError.new("Expected #{v}, got #{k.class}") unless v.include?(k)
		end
	end
end