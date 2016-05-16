require 'yaml'

move_funtion_codes = {002 => :hurtUserQuarter}
$stat_order = [:hp, :attack, :defense, :speed, :special_attack, :special_defense]

# species

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
ary = []
str = ""
species = {}

pokemon = File.open("../PBS/pokemon.txt", "r")
pokemon.pos= 3
# parse file, adding each section to an array
pokemon.each_line do |l|
	if l.match(/^\[\d*\]$/)
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
	sp.id= e.scan(/^InternalName=(.*)$/)[0][0].downcase.to_sym
	sp.name= e.scan(/^Name=(.*)$/)[0][0]
	sp.type1= e.scan(/^Type1=(.*)$/)[0][0].downcase.to_sym
	type = e.scan(/^Type2=(.*)$/)[0]
	sp.type2= type[0].downcase.to_sym if type
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
	sp.height= e.scan(/^Height=(.*)$/)[0][0].to_i
	sp.weight= e.scan(/^Weight=(.*)$/)[0][0].to_i
	sp.kind= e.scan(/^Kind=(.*)$/)[0][0]
	sp.description= e.scan(/^Pokedex=(.*)$/)[0][0]
	species[sp.id] = sp
end

Dir.mkdir("data") unless File.exists?("data")
Dir.mkdir("data/species") unless File.exists?("data/species")
species.each do |id, sp|
	File.open("data/species/#{id}.yaml", "w") { |file| file.write sp.to_yaml }
end