module PKMN

	module Util

		class DataPointer
			
			
		end
	end

	# extend this so you can use klass.is_a? PKMN::DataClass
	module DataClass

		module InstanceMethods

			def to_sym
				self.instance_variable_get(:@type)
			end
		end

		def self.extended(klass)
			id = klass.to_s.scan(/::(\w*)$/)[0][0].snake_case.to_id
			$data_classes[id] = klass
			klass.instance_variable_set(:@type, id)
			class << klass
				include DataClass::InstanceMethods

				attr_accessor :type
			end
		end
	end

	module PKMN::Map

	class Map
		extend PKMN::DataClass

		attr_accessor :id # The symbol by which the map is referred to internally - Symbol
		attr_accessor :tileset # The optional tileset can be specified for a map - Tileset
		attr_accessor :width
		attr_accessor :height
		attr_accessor :encounter_list
		attr_accessor :data
		attr_accessor :events
		attr_accessor :layout # The layout of the tiles - Array(Array(Tile))
		attr_accessor :encounters # The encounters for the map - EncounterList
		attr_accessor :music # Optional sound list for the map - Array(Sound)
		attr_accessor :trainers # Optional list of trainers that appear on the map - Hash(id: Trainer)
		attr_accessor :tiles # A list of tiles that are used to make the map - Array(Tile)
		attr_accessor :weather # A list of weather that can occur on this map - Hash(id: Weather)
		attr_accessor :region # The region this map appears in - Region

	end

	class Tile
		extend PKMN::DataClass

		attr_accessor :id # The symbol by which the tile is referred to internally - Symbol
		attr_accessor :image # The appearance of the tile - Image
		attr_accessor :passage
		attr_accessor :priority
		attr_accessor :terrain_tag

	end

	class Weather
		attr_accessor :id # The symbol by which the weather is referred to internally - Symbol
	end

	class Tileset
		extend PKMN::DataClass

		attr_accessor :id # The symbol by which the tileset is referred to internally - Symbol
		attr_accessor :images
		attr_accessor :image
		attr_accessor :autotiles
		attr_accessor :tiles
		attr_accessor :name
		attr_accessor :tileset_name
		attr_accessor :autotile_names
		attr_accessor :panorama_name
		attr_accessor :panorama_hue
		attr_accessor :fog_name
		attr_accessor :fog_hue
		attr_accessor :fog_opacity
		attr_accessor :fog_blend_type
		attr_accessor :fog_zoom
		attr_accessor :fog_sx
		attr_accessor :fog_sy
		attr_accessor :battleback_name

		def getWidth
			@image.getWidth
		end

		def getHeight
			@image.getHeight
		end

		# def loadImages
		# 	@images = []
		# 	@autotiles = []
		# 	@autotile_names.unshift("").map! { |s| s == "" ? "autotile_blank" : s }
		# 	@autotile_names.each do |e|
		# 		autotile = []
		# 		img = JavaFX::Image.new("/res/img/#{e}.png")
		# 		reader = img.getPixelReader
		# 		if img.getHeight == 128
		# 			8.times do |y|
		# 				6.times do |x|
		# 					img = JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
		# 					autotile << img
		# 				end
		# 			end
		# 			$autotile_def.each do |a|
		# 				tile = JavaFX::WritableImage.new(32, 32)
		# 				writer = tile.getPixelWriter
		# 				writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
		# 				writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
		# 				writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
		# 				writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
		# 				@autotiles << tile
		# 			end
		# 		else
		# 			48.times {@autotiles << JavaFX::WritableImage.new(reader, 0, 0, 32, 32)}
		# 		end
		# 	end
		# 	# @image = JavaFX::Image.new(resource_url(:images, "#{tileset_name}.png").to_s)
		# 	reader = @image.get_pixel_reader
		# 	(@image.getHeight/32).to_i.times do |y|
		# 		8.times do |x|
		# 			@images << JavaFX::WritableImage.new(reader,x*32,y*32,32,32)
		# 		end
		# 	end
		# end

		def getImage(id = 0)
			loadImages if @images.empty?
			id < 384 ? @autotiles[id] : @images[id - 384]
		end

		def eachImageIndex
			loadImages if @images.empty?
			if block_given?
				@images.each_index do |i|
					yield(@images[i], i)
				end
			else
				return @images.each
			end
		end

		def getTile(id)
			loadImages if @images.empty?
			tile = PKMNEE::Tile.new
			tile.image=(getImage(id))
			tile.id=(id)
			tile.passage=(@passages[id])
			tile.priority=(@priorities[id])
			tile.terrain_tag=(@terrain_tags[id])
			tile.tileset_id=(@id)
		end

		def eachTile
			@images.each_index do |i|
				yield(getTile(i))
			end
		end

	end
	
end

	module Species

		class Species
			extend PKMN::DataClass
			
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

		class Type
			extend PKMN::DataClass

			attr_accessor :id
			attr_accessor :name
			attr_accessor :type_class
			attr_accessor :effects

			def initialize(id, name, type_class, effects = {})
				@id = id
				@name = name
				@type_class = type_class
				@effects = effects
			end
			
			def addEffect(id, effect)
				@effects[id] = effect
			end
		end

		# helper to create new types, mainly used by PKMNEE::Import
		def self.new(id, name, type_class, weaknesses, resistances, immunities)
			type = Type.new(id, name, type_class)
			# take the defensive effectiveness of the type and add it to the type
			{little: resistances, very: weaknesses, no: immunities}.each { |effect, types| types.each { |e| type.addEffect(e.to_id, effect) } }
			type # return type
		end
	end

	module Item

		class Item
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
		# class Item < Base
		# 	def initialize(id = nil, name = "", plural_name = "")
		# 		super(id, name, plural_name)
		# 	end
					
		# end

		class Medicine < Item

			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle, :overworld, :pokemon)
			end
			
			
		end

		class Ball < Item

			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle)
			end
			
			
		end

		class TM < Item
			attr_accessor :move # the move that this TM teaches
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon)
			end
					
		end

		class HM < Item
			attr_accessor :move # the move that this HM teaches
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon)
				@permenant = true
			end
					
		end

		class Berry < Item # maybe subclass Medicine?
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld, :pokemon, :battle)
			end
					
		end

		class Mail < Item
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:overworld)
			end
					
		end

		class Battle < Item
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				canUse(:battle, :pokemon)
			end
					
		end

		class KeyItem < Item
			def initialize(id = nil, name = "", plural_name = "")
				super(id, name, plural_name)
				@permenant
			end
					
		end
	end
end