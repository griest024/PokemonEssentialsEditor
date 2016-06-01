
module PKMNEE::Control
	
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
end
