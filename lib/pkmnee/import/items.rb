module PKMNEE::Import

	def self.items
		puts "Importing items..."
		items = {}
		item_file = File.open("#{$rmxp_dir}/PBS/items.txt", "r")
		item_file.pos= 3
		# parse file, adding each section to an array
		item_file.each_line do |line|
			line.force_encoding("UTF-8")
			desc = line.slice!(",\"" + line.scan(/"(.*)"/)[0][0] + "\"") # pulls the description out
			desc.slice!(0..1) # remove leading comma and quotation
			temp = line.split(",") << desc.chop! # gets data and adds description on at end with trailing quote removed
			temp.delete_at(0) # deletes move id number, it is not used 
			item = case temp[3].to_i # get type of item
			when 1 # basic item
				PKMN::Item::Item.new
			when 2 # medicine
				PKMN::Item::Medicine.new
			when 3 # ball
				PKMN::Item::Ball.new
			when 4 # TM
				PKMN::Item::TM.new
			when 5 # Berry
				PKMN::Item::Berry.new
			when 6 # Mail
				PKMN::Item::Mail.new
			when 7 # Battle item
				PKMN::Item::Battle.new
			when 8 # Key item
				PKMN::Item::KeyItem.new
			end
			item.id = (id = temp[0].to_id)
			puts "	#{id}"
			item.name = temp[1]
			item.plural_name = temp[2]
			item.price = temp[4].to_i
			item.description = desc
			items[item.id] = item
		end
		folder = "#{$project_dir}/data/item"
		Dir.mkdir(folder) unless File.exists?(folder)
		items.each do |id, item|
			File.open("#{folder}/#{id}.yaml", "w") { |file| file.write item.to_yaml }
		end
		# $data[:items] = PKMNEE::Util::DataSet.new(PKMN::Item::Base, *(items.values))	
	end
end