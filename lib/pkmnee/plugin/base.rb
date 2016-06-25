
module PKMNEE::Plugin

	class Base 

		def self.inherited(subclass)
			class << subclass

				attr_accessor :id
				attr_reader :instances, :handler, :author, :description, :preview, :name

				def new(data = nil)
					data = data.get
					if data == nil || open?(data) # explicitly check for data being nil, we don't want to let a boolean pass through
						return open(data)
					else
						puts "#{name} is unable to open #{data.class}"
					end
				end

				def initPlugin
					@instances = []
					@handler = DataHandler.new
					@name = "Who the hell knows"
					@author = "Author has chosen to remain anonymous. Yeah you're cool. /s"
					@description = "Is it not self-explanatory?"
					@preview = JavaFX::Image.new("res/img/preview_default.jpg")
					self.init
					self
				end

				def canHandle?(data)
					@handler.canHandle?(data)
				end

				def canOpen?(data)
					canHandle?(data)
				end

				def open?(data)
					canHandle?(data)
				end

				#type: the type of instance to get
				#*controller_args: optional args to pass to instance
				def open(data = nil)
					puts "Opening #{data ? data : "everything"} with #{self}..."
					# @instances << ctrl = @handler.get(data).new(data)
					@handler.get(data).new(data)
				end

				def to_s
					@name
				end

				# Needed so JavaFX can convert this object to a String
				def toString
					to_s
				end
			end
			PKMNEE::Main.declarePlugin(subclass)
		end
	end	
end
