module PKMNEE::Import

	def self.species
		puts "Importing pokemon species..."
		ary = []
		str = ""
		species = {}
		pokemon = File.open("#{$rmxp_dir}/PBS/pokemon.txt", "r")
		pokemon.pos= 3
		# parse file, adding each section to an array
		pokemon.each_line do |l|
			if l.match(/^\[\d*\]/) # checks if line begins section, i.e. [4]
				ary << str
				str = l
			else
				str = str + l
			end
		end
		ary.delete_at(0)

		ary.each do |e|
			e.force_encoding("UTF-8")
			sp = PKMN::Species::Species.new
			sp.number = e.scan(/^\[(\d*)\]$/)[0][0]
			sp.id = (id = e.scan(/^InternalName=(.*)$/)[0][0].to_id)
			puts "	#{id}"
			sp.name = e.scan(/^Name=(.*)$/)[0][0]
			sp.type1 = e.scan(/^Type1=(.*)$/)[0][0].to_id
			type = e.scan(/^Type2=(.*)$/)[0]
			sp.type2 = type[0].to_id if type
			st = e.scan(/^BaseStats=(.*)$/)[0][0].split(",")
			ev = e.scan(/^EffortPoints=(.*)$/)[0][0].split(",")
			sp.stats = {}
			sp.ev_yield = {}
			$stat_order.each_index do |i|
				sp.stats[$stat_order[i]] = st[i].to_i
				sp.ev_yield[$stat_order[i]] = ev[i].to_i
			end
			sp.xp_yield = e.scan(/^BaseEXP=(.*)$/)[0][0].to_i
			sp.catch_rate = e.scan(/^Rareness=(.*)$/)[0][0].to_i
			sp.happiness = e.scan(/^Happiness=(.*)$/)[0][0].to_i
			sp.hatch_steps = e.scan(/^StepsToHatch=(.*)$/)[0][0].to_i
			sp.height = e.scan(/^Height=(.*)$/)[0][0].to_f
			sp.weight = e.scan(/^Weight=(.*)$/)[0][0].to_f
			sp.kind = e.scan(/^Kind=(.*)$/)[0][0]
			sp.description = e.scan(/^Pokedex=(.*)$/)[0][0]
			species[sp.id] = sp
		end
		safe_mkdir (folder = "#{$project_dir}/data/species")
		species.each do |id, sp|
			File.open("#{folder}/#{id}.yaml", "w") { |file| file.write sp.to_yaml }
		end
		# $data[:species] = PKMNEE::Util::DataSet.new(PKMN::Species::Base, *(species.values))
	end	
end
