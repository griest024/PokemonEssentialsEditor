require_relative 'autotile_def'
require_relative 'attr_accessor'
require_relative 'table'
require_relative 'data_set'
require_relative 'nil_class'
require_relative 'symbol'
require_relative 'string'
require_relative 'object'
require_relative 'wrapper'

module PKMNEE::Util

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
end
