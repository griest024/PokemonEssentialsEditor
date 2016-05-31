
module Util

	class NamedLabel < JavaFX::HBox

		def initialize(name, default = "")
			super(5, @name_label = JavaFX::Label.new, JavaFX::Separator.new(JavaFX::Orientation::VERTICAL), @text_label = JavaFX::Label.new)
			@name = JavaFX::SimpleStringProperty.new
			@name.setValue(name.to_s)
			@text = JavaFX::SimpleStringProperty.new
			@text.setValue(text.to_s)
			@name_label.textProperty.bindBidirectional(@name)	
			@text_label.textProperty.bindBidirectional(@text)
			@text_label.setWrapText(true)
			@name_label.setMinSize(JavaFX::Label::USE_PREF_SIZE, JavaFX::Label::USE_PREF_SIZE)
		end

		def name
			@name.get
		end
		
		def name=(value)
			@name.set(value)
		end

		def text
			@text.get
		end

		def text=(value)
			@text.set(value)
		end

		def setWrapText(bool)
			@text_label.setWrapText(bool)
		end
	end

	class DataSet
		attr_accessor :data_class
		attr_accessor :data
		
		def initialize(klass, *data)
			@data = {}
			@data_class = klass
			addData(*data)
		end

		def addData(*data)
			data.each { |e| e.is_a?(@data_class) ? @data[e.id] = e : puts("This DataSet can only contain data of class #{@data_class}") }
		end
		
		def class
			@data_class
		end

		def to_sym
			@data_class.to_sym
		end

		def inspect
			"DataSet<#{@data_class}>, size: #{@data.size}"
		end

		def to_s
			@data_class.to_s
		end
	end

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

class NilClass
	def to_sym
		:nil
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

# monkey-patching object, because I can
class Object
  extend ScopedAttrAccessor
  extend ClassAttrAccessor
  def toString
  	self.to_s
  end
  private
  	# monkey patch method_missing to look for camelCase versions of snake_case methods
  	# broken ATM
	def method_missing(id, *args, &block)
		ary = id.id2name.split("_")
		camel = ary.delete_at(0).downcase
		ary.map! { |e| e.capitalize }
		ary.each { |e| camel.concat(e) }
		camel = camel.to_sym
		if self.respond_to?(camel)
			puts "#{self} recieving camelCase method #{camel} with args #{args}"
			self.send(camel, *args, &block)
		else
			super
		end
	end
end

class String
	# helper method to convert vanilla PKMNEE internal names to lowercase symbols
	def to_id
		downcase.to_sym
	end
end