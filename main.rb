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

require 'java'
require 'jrubyfx'
require 'require_all'


STDOUT.sync = true
STDERR.sync = true

fxml_root(File.dirname(__FILE__) + '/layout')
resource_root(:images, File.join(File.dirname(__FILE__), "res", "img"), "res/img")

$project = '../Pokemon Virginia'

require_relative 'lib'
#everything in these directories will be included
require_rel 'plugins'

$icon = JavaFX::Image.new("/res/img/pkball.gif")

PKMNEE::Main.launch
