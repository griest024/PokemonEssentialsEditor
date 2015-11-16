module Kernel

	def simple_type?(data)
		simple_types = [Fixnum, String, FalseClass, TrueClass]
		simple_types.include?(data.class)
	end

	def simple_type(data)
		simple_type?(data) ? "#{data}" : "#{data.class}, ID: #{data.object_id}"
	end

	def load_yaml(filename)
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
end