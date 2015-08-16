module Foo

	def hi
		"hi"
	end
	
end

module Bar
	include Foo
	
end

class Sandbox

	def initialize
		@a = 1
	end
	
	class Thing
		def initialize
			
		end
	end
	
	
end

class Hello < Sandbox

	def initialize
		puts self.class.a
	end
end

Hello.new