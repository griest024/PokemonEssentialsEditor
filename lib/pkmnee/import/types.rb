module PKMNEE::Import

	def self.types
		puts "Importing types..."
		ary = []
		str = ""
		types = {}

		file = File.open("#{$rmxp_dir}/PBS/types.txt", "r")
		file.pos= 3
		# parse file, adding each section to an array
		file.each_line do |l|
			if l.match(/^\[\d*\]/) # checks if line begins section, i.e. [4]
				ary << str
				str = l
			else
				str = str + l
			end
		end
		ary.delete_at(0)

		ary.each do |e|
			id = e.scan(/^InternalName=(.*)$/)[0][0].to_id
			name = e.scan(/^Name=(.*)$/)[0][0]
			type_class = (e.scan(/^IsSpecialType=true$/).empty? ? :physical : :special)
			# I'm sure this section can be optimized but I don't know enough Ruby/don't want to mess around with eval and bindings
			weaknesses = e.scan(/^Weaknesses=(.*)$/)
			weaknesses = weaknesses[0][0].split(',') unless weaknesses.empty?
			resistances = e.scan(/^Resistances=(.*)$/)
			resistances = resistances[0][0].split(',') unless resistances.empty?
			immunities = e.scan(/^Immunities=(.*)$/)
			immunities = immunities[0][0].split(',') unless immunities.empty?
			##
			type = PKMN::Type.new(id, name, type_class, weaknesses, resistances, immunities)
			types[type.id] = type
		end
		$data[:types] = PKMNEE::Util::DataSet.new(PKMN::Type::Base, *(types.values))
	end
end