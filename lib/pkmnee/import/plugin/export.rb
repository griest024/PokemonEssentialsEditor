#===============================================================================
# Filename:    start_rmxp.rb
#
# Developer:   Raku (rakudayo@gmail.com)
#
# Description: This script creates all plugins in the Plugins directory and
# executes their on_start event methods and starts RMXP.  When RMXP is closed,
# the on_exit event method of each plugin is called.
#===============================================================================

# Setup the project directory from the command-line argument
OS_VERSION = `ver`.strip
# $rmxp_dir = $rmxp_dir
if OS_VERSION.index( "Windows XP" )
  $rmxp_dir = String.new( $rmxp_dir )
elsif OS_VERSION.index( "Windows" )
  $rmxp_dir = String.new( $rmxp_dir ).gsub! "/", "\\"
end

puts "project directory: #{$rmxp_dir}"

$DATA_TYPE = "rxdata"
$RE_EXPORT = true
$plugin_root = File.expand_path(File.dirname(__FILE__))
$plugin_dir = "#{$plugin_root}/plugins"

require_relative 'rmxp/rgss'
require_relative 'common'
require_relative 'plugin_base'

#######################################
#        LOCAL METHODS
#######################################

#=====================================================================
# Method: get_plugin_order
#---------------------------------------------------------------------
# Returns the list of plugins to execute according the specified
# constraints.
#---------------------------------------------------------------------
# event:  The symbol representing the event.  Valid values are
#         :on_start and :on_shutdown
#=====================================================================
def get_plugin_order( event )
	if event == :on_start
	  return PluginBase::get_startup_plugin_order
	else
	  return PluginBase::get_shutdown_plugin_order
	end
end


#######################################
#             SCRIPT
#######################################

["export", "export/data", "export/scripts"].each { |e| Dir.mkdir("#{$rmxp_dir}/#{e}") unless File.exists?("#{$rmxp_dir}/#{e}") }

# Get the list of plugins in the plugin directory
plugins = Dir.entries( "#{$plugin_root}/plugins" )
plugins = plugins.select { |filename| File.extname(filename) == ".rb" }

puts "plugins: #{plugins}"

# FIX: For TextMate's annoying habit of creating backup files automatically
#      that still have the .rb extension.
plugins = plugins.select { |filename| filename.index("._") != 0 }

# Evaluate each plugin
plugins.each do |plugin|
  plugin_path = "#{$plugin_dir}/" + plugin
  File.open( plugin_path, "r+" ) do |infile|
    code = infile.read( File.size( plugin_path ) )
    eval( code )
  end
end

# Get the list of plugins in the shutdown order
plugins = get_plugin_order( :on_exit )

# Create each plugin object
plugins.collect! {|plugin| eval( plugin + ".new" )}

# Execute each plugin's on_exit event
plugins.each do |plugin|
  plugin.on_exit
end