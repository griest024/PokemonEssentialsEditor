module Util::DSL
	def with(context, *properties)
		if properties.is_a?(Hash)
			properties.each do |k,v|
				context.send(k, v)
			end
		end
	end
end