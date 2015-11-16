module PKMN
	class Game

		attr_accessor :name # The name of the game - String
		attr_accessor :regions # The regions in the game - Hash(id: Region)
		attr_accessor :species # All the species available - Hash(id: Species)
		attr_accessor :evo_types # All the evolution types available - Hash(id: EvolutionType)
		attr_accessor :items # All the items available - Hash(id: Item)
		attr_accessor :trainers # Contains all trainers and gym leaders - Hash(id: Trainer)
		attr_accessor :types # The pokemon types used in the game - Hash(id: Type)
		attr_accessor :tilesets	# The optional tilesets that maps can use - Hash(id: Tileset)
		attr_accessor :tiles # All the tiles that appear in the game - Array(Tile)
		attr_accessor :music # The soundtrack for the game - Hash(id: Sound)
		attr_accessor :badges # The badges the player can attain - Hash(id: Badge)
		attr_accessor :moves # The moves that Pokemon can learn - Hash(id: Move)
		attr_accessor :hms # List of the HMs in the game - Array(HM)
		attr_accessor :tms # List of the TMs in the game - Array(TM)
		attr_accessor :stats # The stats that are used in the game - Hash(stat: String)
		attr_accessor :abilities # Abilities available - Hash(id: Ability)
		attr_accessor :natures # The natures available in the game - Hash(id: Nature)
		attr_accessor :player # The current (loaded) player - Player

	end

	class Item


		def initialize(args)
			
		end
		
		
	end

	class Bag

		attr_accessor :items
		attr_accessor :categories


		def initialize(*items)
			
		end

		def addItems(*items)
			args = {}
			items.each { |e| args[e] = Item }
		end

		def add(item)
			addItems(item)
		end
		
		
	end

	# Represents the player. This class is slightly bloated so as to allow an instance to
	# function as a save. ***Consider changing this***
	class Player

		attr_accessor :pokedex # The pokedex the game uses - Pokedex
		attr_accessor :bag # The bag that the game uses - Bag
		attr_accessor :name # The player's name
		attr_accessor :pokemon # The pokemon in the player's party - Array(Pokemon)
		attr_accessor :pc


		def initialize(name)
			name= name
			bag= Bag.new
			pokedex= Pokedex.new
		end
		
		
	end

	class Region
		attr_accessor :id # The symbol by which the region is referred to internally - Symbol
		attr_accessor :name # The name that is displayed to the player - String
		attr_accessor :maps # The maps that are used in the region - Hash(id: Map)
		attr_accessor :map # Stores the layout of the maps - RegionMap
	end

	class EncounterList
		attr_accessor :id # The symbol by which the encounters are referred to internally - Symbol

	end

	class Species
		attr_accessor :id # The symbol by which the species is referred to internally - Symbol
		attr_accessor :stats # The stat weights for the species, keys must match Game.stats - Hash(stat: Number)
		attr_accessor :sprite # The appearance of the pokemon ingame - Sprite
		attr_accessor :battle_sprite # The appearance of the pokemon in battle
		attr_accessor :name # The name of the species displayed ingame - String
		attr_accessor :evolutions # The possible evolutions of this species - Hash(evo_type.id: Species)
		attr_accessor :level_moves # The moves the species learns by leveling up - Array(Move)
		attr_accessor :tm_moves # The moves the species learns by TM - Array(ToF)
		attr_accessor :hm_moves # The moves the species learns by HM - Array(ToF)
		attr_accessor :description # A description of the species (displayed by pokedex) - String
		attr_accessor :cry # The sound that the species makes - Sound
		attr_accessor :habitat # The regions and maps this species can be found - Hash(Region.id: Array(Map))
		attr_accessor :xp_level # The total xp required to reach each level - Array(Number)
		attr_accessor :abilities # The abilities that this species can have - Array(Ability)
	end

	class Pokemon
		attr_accessor :name # The (nick)name of the pokemon, defaults to species.name - String
		attr_accessor :species # The species of the pokemon - Species
		attr_accessor :hp # Current HP of pokemon, defaults to stats[:hp] - Number
		attr_accessor :moves # The moves the pokemon currently knows, defaults to  - Array[4](Move)
		attr_accessor :level # The current level of the pokemon - Number(1-100)
		attr_accessor :xp # The current amount of XP this pokemon has, defaults to species.xp_level[level] - Number
		attr_accessor :ability # The ability the pokemon has - Ability
		attr_accessor :evs # The EVs of the pokemon - Hash(stat: Number(0-31))
		attr_accessor :ivs # The IVs of the pokemon, default to random numbers between 0,31 - Hash(stat: Number(0-31))
		attr_accessor :stats # The current stats of the pokemon - Hash(stat: Number)
		attr_accessor :nature # The nature of the pokemon, defaults to random Game.natures - Nature
		attr_accessor :ot # The name of the trainer that captured this pokemon, defaults to player.name - String
		attr_accessor :id # The id of the pokemon, defaults to random - Number(0-65535)

		def initialize(species, level = 1)
			typeCheck(species => Species, level => Number)
			rand = Random.new
			name= species.name
			xp= species.xp_level[level]
			evs= {}
			$game.stats.each { |k,v| evs[k] = 0 }
			ivs= {}
			$game.stats.each { |k,v| ivs[k] = rand.rand(31) }
			calculate_stats
			hp= stats[:hp]
			ot= $player.name
			nature= $game.natures.values.sample
			ability= species.abilities.sample
			secret_id= rand.rand(65535)
		end

		private :id=
	end

	class Battle

		attr_accessor :participants

		def initialize(args)
			
		end
		
		
	end

	# In battle conditional effect that every pokemon has
	class Ability
		attr_accessor :id # The symbol by which the ability is referred to internally - Symbol
		attr_accessor :name #
		attr_accessor :condition # The optional expression that must evaluate to true before effect is applied - Proc
		attr_accessor :effect # The effect the ability has - Proc

		def initialize(:id)
			
		end

		def condition?
			condition.call
		end

		def call(battle)
			effect.call(battle)
		end

		private :id=
	end

	class Move
		attr_accessor :id # The symbol by which the move is referred to internally - Symbol
		attr_accessor :name # The name that is displayed to player - String
		attr_accessor :type # The type of the move - Type
		attr_accessor :max_pp # The maximum pp of the move - Number
		attr_accessor :power # The power of the move - Number
		attr_accessor :accuracy # The accuracy of the move - Number
		attr_accessor :effect # The optional effect of the move - Proc
		attr_accessor :description # Description of the move - String
	end

	class Trainer
		attr_accessor :id # The symbol by which the trainer is referred to internally - Symbol
		attr_accessor :name # The name that is displayed to the player
		attr_accessor :sprite # The appearance of the trainer in the overworld
		attr_accessor :battle_sprite # The appearance of the trainer in battle
	end
end