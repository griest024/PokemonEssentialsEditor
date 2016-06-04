class Java::JavafxSceneLayout::Region

	def bindHeightToScene
		prefHeightProperty.bind(getScene.heightProperty)
	end

	def bindWidthToScene
		prefWidthProperty.bind(getScene.widthProperty)
	end

	def bindSizeToScene
		bindHeightToScene
		bindWidthToScene
	end
end

class Java::JavafxScene::Node

	def setNodeSize(width, height)
		setMinWidth(width)
		setMaxWidth(width)
		setMinHeight(height)
		setMaxHeight(height)
	end
end