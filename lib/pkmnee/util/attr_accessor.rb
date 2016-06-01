
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

# This module defines class  attribute accessors
# Each method only takes one variable name (without the @@) and an optional value
# Getters and setters are defined at class level
module ClassAttrAccessor
	def class_attr_accessor(name, value = nil)
		name = name.to_sym
		self.class_variable_set("@@#{name}".to_sym, value)
		self.define_singleton_method(name) { self.class_variable_get("@@#{name}".to_sym)}
		self.define_singleton_method("#{name}=".to_sym) { |v| self.class_variable_set("@@#{name}".to_sym, v) }
	end
	def class_attr_writer(name, value = nil)
		name = name.to_sym
		self.class_variable_set("@@#{name}".to_sym, value)
		self.define_singleton_method("#{name}=".to_sym) { |v| self.class_variable_set("@@#{name}".to_sym, v) }
	end
	def class_attr_reader(name, value = nil)
		name = name.to_sym
		self.class_variable_set("@@#{name}".to_sym, value)
		self.define_singleton_method(name) { self.class_variable_get("@@#{name}".to_sym)}
	end
end
