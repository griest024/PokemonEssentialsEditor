require 'yaml'
module PKMN

	module DataClass

		module InstanceMethods

			def to_sym
				self.instance_variable_get(:@type)
			end
		end
		
		def self.extended(klass)
			$data_classes << klass
			klass.instance_variable_set(:@type, klass.to_s.downcase.to_sym)
			class << klass
				include DataClass::InstanceMethods
			end
		end
	end

	module Type

		class Base
			include DataClass

			attr_accessor :id
			attr_accessor :name
			attr_accessor :class
			attr_accessor :effects

			def initialize(id, name, type_class, effects = {})
				@id = id
				@name = name
				@class = type_class
				@effects = effects
			end
			
			def addEffect(id, effect)
				@effect[id] = effect
			end
		end

		# helper to create new types, mainly used by PKMNEE::Import
		def self.new(id, name, type_class, weaknesses, resistances, immunities)
			type = Base.new(id, name, type_class)
			{little: resistances, very: weaknesses, no: immunities}.each { |effect, types| types.each { |e| type.addEffect(e, effect) } }
		end
	end

	module Item

		class Base
			extend PKMN::DataClass

			attr_accessor :id
			attr_accessor :name
			attr_accessor :plural_name
			attr_accessor :price
			attr_accessor :description
			attr_accessor :usability
			attr_accessor :effect
			attr_accessor :permenant
			attr_accessor :hold_item

			def initialize(id = nil, name = "", plural_name = "")
				@id = id
				@name = name
				@plural_name = plural_name
				@price = 0
				@description = ""
				@usability = {}
				@usability.default = false
				@permenant = false
				@hold_item = true
			end

			# checks if the item can be used in the given context
			def canUse?(context)
				@usability[context]
			end

			def use?(context)
				canUse?(context)
			end

			def canUse(*contexts)
				addUsabilityContext(*contexts)
			end

			# specifies that this item can be used in the contexts
			def addUsabilityContext(*contexts)
				contexts.each { |e| @usability[e] = true }
			end

			# callback invoked when this item is used
			def used(reciever)
				
			end
			
			# callback invoked when this item is held
			def held(pkmn)
				
			end

			# alias for can_hold?
			def hold?
				canHold?
			end

			# specifies if this item can be held
			def canHold?
				@hold_item
			end
			
		end
		class Item < Base
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
			end
					
		end

		class Medicine < Base

			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle, :overworld, :pokemon)
			end
			
			
		end

		class Ball < Base
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle)
			end
			
			
		end

		class TM < Base
			attr_accessor :move # the move that this TM teaches
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon)
			end
					
		end

		class TM < Base
			attr_accessor :move # the move that this TM teaches
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon)
			end
					
		end

		class Berry < Base # maybe subclass Medicine?
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon, :battle)
			end
					
		end

		class Mail < Base
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld)
			end
					
		end

		class Battle < Base
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle, :pokemon)
			end
					
		end

		class KeyItem < Base
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
			end
					
		end
	end
end
module PKMNEE
	module Import

		$project_dir = "C:/Users/Peter/PokemonEssentialsEditor/src"
		move_funtion_codes = {002 => :hurtUserQuarter}
		$stat_order = [:hp, :attack, :defense, :speed, :special_attack, :special_defense]

############################################## SPECIES #############################################

		class Species
			attr_accessor :id # The symbol by which the species is referred to internally - Symbol
			attr_accessor :stats # The stat weights for the species, keys must match Game.stats - Hash(stat: Number)
			attr_accessor :sprite # The appearance of the pokemon ingame - Sprite
			attr_accessor :battle_sprite # The appearance of the pokemon in battle
			attr_accessor :name # The name of the species displayed ingame - String
			attr_accessor :evolutions # The possible evolutions of this species - Hash(evo_type.id: Species)
			attr_accessor :moveset # The moves the species learns by leveling up - Array(Move)
			attr_accessor :tm_moves # The moves the species learns by TM - Array(ToF)
			attr_accessor :hm_moves # The moves the species learns by HM - Array(ToF)
			attr_accessor :description # A description of the species (displayed by pokedex) - String
			attr_accessor :cry # The sound that the species makes - Sound
			attr_accessor :habitat # The regions and maps this species can be found - Hash(Region.id: Array(Map))
			attr_accessor :xp_level # The total xp required to reach each level - Array(Number)
			attr_accessor :abilities # The abilities that this species can have - Array(Ability)
			attr_accessor :xp_yield
			attr_accessor :ev_yield
			attr_accessor :catch_rate
			attr_accessor :happiness
			attr_accessor :hatch_steps
			attr_accessor :egg_groups
			attr_accessor :height
			attr_accessor :weight
			attr_accessor :color
			attr_accessor :kind
			attr_accessor :abilities
			attr_accessor :hidden_abilities
			attr_accessor :egg_moves
			attr_accessor :habitat
			attr_accessor :region
			attr_accessor :number
			attr_accessor :type1
			attr_accessor :type2
		end
		def self.species
			ary = []
			str = ""
			species = {}

			pokemon = File.open("#{$project_dir}/PBS/pokemon.txt", "r")
			pokemon.pos= 3
			# parse file, adding each section to an array
			pokemon.each_line do |l|
				if l.match(/^\[\d*\]$/) # checks if line begins section, i.e. [4]
					ary << str
					str = l
				else
					str = str + l
				end
			end
			ary.delete_at(0)

			ary.each do |e|
				sp = Species.new
				sp.number= e.scan(/^\[(\d*)\]$/)[0][0]
				sp.id= e.scan(/^InternalName=(.*)$/)[0][0].to_id
				sp.name= e.scan(/^Name=(.*)$/)[0][0]
				sp.type1= e.scan(/^Type1=(.*)$/)[0][0].to_id
				type = e.scan(/^Type2=(.*)$/)[0]
				sp.type2= type[0].to_id if type
				st = e.scan(/^BaseStats=(.*)$/)[0][0].split(",")
				ev = e.scan(/^EffortPoints=(.*)$/)[0][0].split(",")
				sp.stats= {}
				sp.ev_yield= {}
				$stat_order.each_index do |i|
					sp.stats[$stat_order[i]] = st[i].to_i
					sp.ev_yield[$stat_order[i]] = ev[i].to_i
				end
				sp.xp_yield= e.scan(/^BaseEXP=(.*)$/)[0][0].to_i
				sp.catch_rate= e.scan(/^Rareness=(.*)$/)[0][0].to_i
				sp.happiness= e.scan(/^Happiness=(.*)$/)[0][0].to_i
				sp.hatch_steps = e.scan(/^StepsToHatch=(.*)$/)[0][0].to_i
				sp.height= e.scan(/^Height=(.*)$/)[0][0].to_f
				sp.weight= e.scan(/^Weight=(.*)$/)[0][0].to_f
				sp.kind= e.scan(/^Kind=(.*)$/)[0][0]
				sp.description= e.scan(/^Pokedex=(.*)$/)[0][0]
				species[sp.id] = sp
			end
			$data[:species] = Util::DataSet.new(Species, *(species.values))
		end



############################################## ITEMS ##########################################

		def self.items
			items = {}
			item_file = File.open("#{$project_dir}/PBS/items.txt", "r")
			item_file.pos= 3
			# parse file, adding each section to an array
			item_file.each_line do |line|
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
				else
					PKMN::Item::Base.new
				end
				item.id = temp[0].to_id
				item.name = temp[1]
				item.plural_name = temp[2]
				item.price = temp[4].to_i
				item.description = desc
				items[item.id] = item
			end
			# p items
			$data[:items] = Util::DataSet.new(PKMN::Item::Base, *(items.values))
			# Dir.mkdir("data") unless File.exists?("data")
			# Dir.mkdir("data/species") unless File.exists?("data/species")
			# species.each do |id, sp|
			# 	File.open("data/species/#{id}.yaml", "w") { |file| file.write sp.to_yaml }
			# end
			# Dir.mkdir("data/items") unless File.exists?("data/items")
			# items.each do |id, item|
			# 	File.open("data/items/#{id}.yaml", "w") { |file| file.write item.to_yaml }
			# end
		end
	end
end
