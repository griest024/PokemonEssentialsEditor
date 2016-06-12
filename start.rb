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

#suppress annoying warnings
$stderr = StringIO.new

# load gems
require 'java'
# require 'jrubyfx'
# require_relative 'lib/fxmlloader/pkg/jrubyfx-fxmlloader-0.4.1-java/lib/jrubyfx-fxmlloader'
require_relative 'lib/jrubyfx/lib/jrubyfx'
require 'require_all'
require 'yaml'
require 'psych'
require_relative 'lib/jvyamlb.jar'

STDOUT.sync = true
STDERR.sync = true

$root_dir = File.expand_path(File.dirname(__FILE__))
$project_dir = "#{$root_dir}/project"

# init module so declaring submodules is quicker
module PKMNEE; end

# load library
require_relative 'lib/lib'

#load plugins
require_rel 'plugins'

fxml_root(File.dirname(__FILE__) + '/layout')
resource_root(:images, File.join(File.dirname(__FILE__), "res", "img"), "res/img")
resource_root(:graphics, File.join(File.dirname(__FILE__), "src", "Graphics"), "src/Graphics")
resource_root(:tiles, File.join(File.dirname(__FILE__), "project", "res", "tiles"), "project/res/tiles")

$icon = JavaFX::Image.new("/res/img/pkball.gif")

PKMNEE::Main.launch
