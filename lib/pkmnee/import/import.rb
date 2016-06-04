require_relative 'plugin/rmxp/rgss'
require_relative 'pkmn'
require_relative 'items'
require_relative 'maps'
require_relative 'species'
require_relative 'types'

module PKMNEE
	module Import

		move_funtion_codes = {002 => :hurtUserQuarter}
		$stat_order = [:hp, :attack, :defense, :speed, :special_attack, :special_defense]
		$rmxp_dir = "#{$root_dir}/src"

		def self.rxdata
			require_relative 'plugin/export.rb' # change this to PKMNEE::Import::Plugin.export once rxdata plugin is namespaced
		end

		def self.all
			# rxdata
			puts "Importing everything..."
			maps
			types
			species
			items
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
