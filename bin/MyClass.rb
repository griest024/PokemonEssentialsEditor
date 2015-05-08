
class 

	include GladeGUI

	def before_show()
		@button1 = "Hello World"
	end	

	def button1__clicked(*args)
		@builder["button1"].label = @builder["button1"].label == "Hello World" ? "Goodbye World" : "Hello World"
	end

end

