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

	def setNodeSize(node, width, height)
		node.setMinWidth(width)
		node.setMaxWidth(width)
		node.setMinHeight(height)
		node.setMaxHeight(height)
	end
end