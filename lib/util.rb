module Util

	class FractionFormatter < JavaFX::StringConverter

		def toString(dbl)
			dbl == 1 ? "1" : dbl.to_r.to_s
		end

		def fromString(str)
			str.to_r.to_f
		end
	end

	class FileComboBox < JavaFX::ComboBox

		def initialize(*filetypes)
			
		end
		
		
	end

	#NOT USED
	class PluginListCell < JavaFX::ListCell
		
		def update_item(item, empty)
			super(item, empty)
			setText(item.class.name) if item != null
		end
	end
	#NOT USED
end

module JRubyFX::Displayable
	
	def control
		self.instance_variable_get :@control
	end

	def getControl
		control
	end

	def ctrl
		control
	end

	private
	
	def control=(value)
		self.instance_variable_set :@control, value
	end

	def setControl(value)
		control= value
	end

	def ctrl=(value)
		control= value
	end
end


# This module adds scoped accessor methods to Ruby Classes. For
# example:
#
# class Foo
#   private_attr_reader :thing1, :thing2, :thing3
#   protected_attr_writer :counter
#   protected_attr_accessor :flagbag
# end
#
# They work exactly the same as the regular ruby attr_accessor
# methods, except they are placed in the appropriate public or
# private scope as desired.
#
# Explore the code at your leisure, but if you just want to know if it
# works on your version of ruby, just run it. You'll need
# minitest/autorun installed--the tests are the bottom half of the
# file. If you are running Ruby 1.9.3 you'll need to install the
# minitest gem; if you are running Ruby 2 it's part of the Standard
# Library.
#
# Author: dbrady
module ScopedAttrAccessor
  def private_attr_reader(*names)
    attr_reader(*names)
    names.each {|name| private name}
  end

  def private_attr_writer(*names)
    attr_writer(*names)
    names.each {|name| private "#{name}=" }
  end

  def private_attr_accessor(*names)
    attr_accessor(*names)
    names.each {|name| private name; private "#{name}=" }
  end

  def protected_attr_reader(*names)
    protected
    attr_reader(*names)
  end

  def protected_attr_writer(*names)
    protected
    attr_writer(*names)
  end

  def protected_attr_accessor(*names)
    protected
    attr_accessor(*names)
  end
end

# monkey-patching object, because I can
class Object
  extend ScopedAttrAccessor

  private
  	# monkey patch method_missing to look for camelCase versions of snake_case methods
	def method_missing(id, *args, &block)
		ary = id.id2name.split("_")
		camel = ary.delete_at(0).downcase
		ary.map! { |e| e.capitalize }
		ary.each { |e| camel.concat(e) }
		camel = camel.to_sym
		if self.respond_to?(camel)
			self.send(camel, *args, &block)
		else
			super
		end
	end
end