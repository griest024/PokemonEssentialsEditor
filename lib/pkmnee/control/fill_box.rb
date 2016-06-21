
class PKMNEE::Control::FillBox < JavaFX::GridPane

	def initialize(node = nil)
		super()
		setStyle("-fx-background-color:red")
		cCon = JavaFX::ColumnConstraints.new
		rCon = JavaFX::RowConstraints.new
		cCon.setFillWidth true
		rCon.setFillHeight true
		cCon.setHgrow JavaFX::Priority::ALWAYS
		rCon.setVgrow JavaFX::Priority::ALWAYS
		getColumnConstraints.add cCon
		getRowConstraints.add rCon
		add node if node
	end
	
	def add(node)
		super(node, 0, 0)
	end
end
