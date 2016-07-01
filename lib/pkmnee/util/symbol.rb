
class Symbol

	def to_id
		downcase
	end

	def to_name
		str = ""
		to_s.split('_').each.with_index do |e, i|
			i == 0 ? str = e.capitalize : str << " #{e.capitalize}"
		end
		str
	end
end
