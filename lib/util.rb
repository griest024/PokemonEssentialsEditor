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