
class String

	# helper method to convert vanilla PKMNEE internal names to lowercase symbols
	def to_id
		gsub(/ /, '_').downcase.to_sym
	end

	def camelCase
		ret = ""
		split("_").each.with_index do |s, i|
			i == 0 ? ret = s.downcase : ret << s.capitalize
		end
		ret
	end
end
