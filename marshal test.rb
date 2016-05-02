require 'rubygems'
require 'require_all'
# require 'sdl'
# require 'openrgss'

# require_relative 'OpenRGSS/lib/rgss'

# require_rel '../Pokemon Virginia1/src/Scripts/Scripts'
# require 'OpenRGSS/lib/openrgss/rgss'

# require 'OpenRGSS/lib/openrgss/bitmap'
# require 'OpenRGSS/lib/openrgss/color'
# require 'OpenRGSS/lib/openrgss/font'


# digest = File.new("../Pokemon Virginia1/src/Scripts/Scripts/digest.txt", "r")

load_order = []

File.open("../Pokemon Virginia1/src/Scripts/Scripts/digest.txt", "r") do |file| 
	file.each_line do |line|
		load_order.concat(line.scan(/\w*.rb$/))
	end
end

load_order.each do |s|
	require("../Pokemon Virginia1/src/Scripts/Scripts/".concat(s))
end