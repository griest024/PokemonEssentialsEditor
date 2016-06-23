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

class Java::JavafxStage::Stage

	@log_stages = false
	
	def self.new
		stage = super
		@log_stages ? PKMNEE::Main.addChildStage(stage) : stage
	end

	def self.startLogging
		@log_stages = true
	end
end

class Java::JavafxScene::Node

	def setSize(width, height)
		setMinWidth(width)
		setMaxWidth(width)
		setMinHeight(height)
		setMaxHeight(height)
	end

	def anchor
		PKMNEE::Control::AnchorPane.new(self)
	end
end

class Java::JavafxSceneImage::Image
	def equals(img)
		ret = getHeight == img.getHeight && getWidth == img.getWidth
		this_reader = getPixelReader
		other_reader = img.getPixelReader
		if ret
			getWidth.to_i.times do |x|
				getHeight.to_i.times do |y|
					ret = ret && this_reader.getArgb(x, y) == other_reader.getArgb(x, y)
				end
			end
		end
		ret
	end
end

class Java::JavafxSceneImage::WritableImage
	def equals(img)
		ret = getHeight == img.getHeight && getWidth == img.getWidth
		this_reader = getPixelReader
		other_reader = img.getPixelReader
		if ret
			getWidth.to_i.times do |x|
				getHeight.to_i.times do |y|
					ret = ret && this_reader.getArgb(x, y) == other_reader.getArgb(x, y)
				end
			end
		end
		ret
	end
end