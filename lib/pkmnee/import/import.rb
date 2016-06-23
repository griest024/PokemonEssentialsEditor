require_relative 'plugin/rmxp/rgss'
require_relative 'items'
require_relative 'maps'
require_relative 'species'
require_relative 'types'

module PKMNEE
	module Import

		move_funtion_codes = {002 => :hurtUserQuarter}
		$stat_order = [:hp, :attack, :defense, :speed, :special_attack, :special_defense]
		$rmxp_dir = "#{$root_dir}/src"
		safe_mkdir "#{$project_dir}", "#{$project_dir}/data", "#{$project_dir}/res"

		def self.rxdata
			require_relative 'plugin/export.rb' # change this to PKMNEE::Import::Plugin.export once rxdata plugin is namespaced
		end

		def self.all
			rxdata
			puts "Importing everything..."
			maps
			types
			species
			items
		end
	end
end
