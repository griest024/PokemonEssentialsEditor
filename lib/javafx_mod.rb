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