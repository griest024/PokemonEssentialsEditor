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

	def typeCheck(args = {}, detailed? = false)
		puts "typeCheck start"
		# detailed? ? msg = "Expected #{v}, you gave #{k.class}."
		raise ArgumentError.new("Pass params and types in as keys and values, respectively.") if !args.is_a?(Hash)
		puts "typeCheck: got the hash"
		args.each_pair do |k,v|
			raise ArgumentError.new("Values should be type Class") if !v.is_a?(Class)
			raise ArgumentError.new("Expected #{v}, #{caller[0]} gave #{k.class}") if !k.is_a?(v)
		end
	end
end