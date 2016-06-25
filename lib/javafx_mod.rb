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

	@@global_parent = nil
	@@global_children = []

	def self.new
		stage = super
		@@global_children << stage if @@global_parent
		stage.addEventHandler JavaFX::WindowEvent::WINDOW_CLOSE_REQUEST, lambda { |event| event.getTarget.class.global_children.delete stage }
		stage
	end

	def self.global_children
		@@global_children
	end

	def setGlobalParent
		addEventHandler JavaFX::WindowEvent::WINDOW_CLOSE_REQUEST, lambda { |event| event.getTarget.class.global_children.each { |stage| stage.close } }
		@@global_parent = self
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