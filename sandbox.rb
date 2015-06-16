module Foo

	def hi
		"hi"
	end
	
end

module Bar
	include Foo
	
end

class Sandbox
	include Bar
	def self.a
		"asdfadsf"
	end
	
	
end

class Hello < Sandbox

	def initialize
		puts self.class.a
	end
end

Hello.new