
class PKMNEE::Control::NewProject < JavaFX::Dialog

	def initialize
		super

		@pane = getDialogPane

		setTitle "Create a new project"
		setHeaderText "Enter project information below"

		confirm = JavaFX::ButtonType.new "OK", JavaFX::ButtonBar::ButtonData::OK_DONE
		@pane.getButtonTypes.addAll confirm, JavaFX::ButtonType::CANCEL

		box = JavaFX::VBox.new 10, author = JavaFX::TextField.new, name = JavaFX::TextField.new

		author.setPromptText "Author"
		name.setPromptText "Project Name"

		@pane.lookupButton(confirm).disableProperty.bind JavaFX::Bindings.or(author.emptyProperty, name.emptyProperty)

		@pane.setContent box

		setResultConverter lambda { |button| {name: name.getText, author: author.getText} if button == confirm }
	end
	
	# possibly unnecessary if pane is available in constructor
	def pane
		getDialogPane
	end
end
