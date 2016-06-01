module PKMN

	# extend this so you can use klass.is_a? PKMN::DataClass
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

	module Species

		class Base
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
	end

	module Type

		class Base
			extend PKMN::DataClass

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
				@effects[id] = effect
			end
		end

		# helper to create new types, mainly used by PKMNEE::Import
		def self.new(id, name, type_class, weaknesses, resistances, immunities)
			type = Base.new(id, name, type_class)
			# take the defensive effectiveness of the type and add it to the type
			{little: resistances, very: weaknesses, no: immunities}.each { |effect, types| types.each { |e| type.addEffect(e.to_id, effect) } }
			type # return type
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