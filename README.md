	
Alternative editor for PKMN Essentials RMXP project (http://pokemonessentials.wikia.com/wiki/Pok%C3%A9mon_Essentials_Wiki).
Written in ruby and uses JavaFX with JRubyFX.

	Copyright (C) 2015 - Peter Lauck (griest)

    This program is free software: you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation, either version 3 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License
    along with this program.  If not, see <http://www.gnu.org/licenses/>.



TODO
====

General
-------

- [x] TRANSITION TO JAVAFX 8

- [ ] Readables
- [ ] Access control, change certain plugin/controller functionality to protected
- [ ] Add FileChooser
- [x] Open plugin popup
	- [x] Find a better way to get plugin list to plugin popup ()
- [x] Add file handling protocols to plugin architecture
- [x] Automatically load all data files into main (can do this but DON'T!!!!)
- [ ] Convert yaml data into native objects (tiles, maps, etc.)

- [ ] Add context menus
- [ ] Bind node properties to instance variable (node children, etc.)
- [ ] Store Application configuration
- [ ] General menu creation
- [ ] FileComboBox
- [x] Redesign file scheme (namespace author names) with autoload_all
- [ ] PluginIdentity
- [ ] Import RMXP projects
    - [x] items
        - [ ] berry plants
        - [ ] tm/hm
    - [x] type
    - [x] species
    - [ ] trainers
    - [ ] maps
        - [ ] encounter lists
    - [ ] tiles/tilesets
    - [ ] music
    - [ ] moves
    - [ ] town map/map connnections
    - [ ] abilities
    - [ ] natures
    - [ ] events
    - [ ] animations
    - [ ] all sprites/graphics
    - [ ] game


Plugins
-------

### Editor:
- [ ] Convert to plugin

### Map:
- [ ] Make config 
- [ ] multiple tile selection

### Raw Data:
- [x] Accordion file browser
- [ ] make config
- [x] add children to DataTree dynamically
