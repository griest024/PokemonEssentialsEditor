
class PKMNEE::Control::AnchorPane < JavaFX::AnchorPane

	def initialize(*nodes)
		super
		nodes.each { |node| setAnchors node }
	end
	
	def setAnchors(node, top = 0.0, bottom = 0.0, left = 0.0, right = 0.0)
		JavaFX::AnchorPane.setTopAnchor node, top
		JavaFX::AnchorPane.setBottomAnchor node, bottom
		JavaFX::AnchorPane.setLeftAnchor node, left
		JavaFX::AnchorPane.setRightAnchor node, right
	end
end
