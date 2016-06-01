
class String
	# helper method to convert vanilla PKMNEE internal names to lowercase symbols
	def to_id
		downcase.to_sym
	end
end
