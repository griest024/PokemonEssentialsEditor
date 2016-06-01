
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
