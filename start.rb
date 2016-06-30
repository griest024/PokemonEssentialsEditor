 #    Copyright (C) 2015 - Peter Lauck (griest)

 #    This program is free software: you can redistribute it and/or modify
 #    it under the terms of the GNU General Public License as published by
 #    the Free Software Foundation, either version 3 of the License, or
 #    (at your option) any later version.

 #    This program is distributed in the hope that it will be useful,
 #    but WITHOUT ANY WARRANTY; without even the implied warranty of
 #    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 #    GNU General Public License for more details.

 #    You should have received a copy of the GNU General Public License
 #    along with this program.  If not, see <http://www.gnu.org/licenses/>.

#!/usr/bin/ruby

# suppress annoying warnings
$stderr = StringIO.new

# configure root directory
$root_dir = File.expand_path(File.dirname(__FILE__))

# configure load path
$LOAD_PATH.unshift("#{$root_dir}/lib/pkmnee", "#{$root_dir}/lib")

# load gems
require 'java'
require 'jrubyfx'
require 'require_all'
require 'yaml'
require 'psych'
require 'benchmark'

# load modifications to the kernel
require 'kernel'

STDOUT.sync = true
STDERR.sync = true

$LOAD_PATH.unshift("#{$root_dir}/lib/pkmnee") 

# init module so declaring submodules is quicker
module PKMNEE; end

# load library
require_relative 'lib/lib'

# load plugins
require_rel 'plugins'

fxml_root(File.join(File.dirname(__FILE__), "res", "fxml"))
resource_root(:images, File.join(File.dirname(__FILE__), "res", "img"), "res/img")
resource_root(:css, File.join(File.dirname(__FILE__), "res", "css"), "res/css")
resource_root(:graphics, File.join(File.dirname(__FILE__), "pkmne", "Graphics"), "pkmne/Graphics")
resource_root(:tiles, File.join(File.dirname(__FILE__), "project", "res", "tile"), "project/res/tile")
resource_root(:autotiles, File.join(File.dirname(__FILE__), "project", "res", "autotile"), "project/res/autotile")

$icon = JavaFX::Image.new("/res/img/pkball.gif")

$blank_tile = JavaFX::WritableImage.new(32, 32)
$black_tile = JavaFX::Image.new(resource_url(:images, "black_tile.png").to_s)

PKMNEE::Main.launch
