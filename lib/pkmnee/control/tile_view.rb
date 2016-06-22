
class PKMNEE::Control::TileView < JavaFX::StackPane

	attr_accessor :tile, :image, :isSelected

	@@select_images = {:single => "single", :left => "left-edge", :right => "right-edge", :top => "top-edge", :bottom => "bottom-edge", :ne => "ne-corner", :nw => "nw-corner", :se => "se-corner", :sw => "sw-corner", :no_right => "right-missing", :no_left => "left-missing", :no_top => "top-missing", :no_bottom => "bottom-missing"}

	def initialize(tile)
		@tile = tile
		@image = @tile.getImage
		super(@image_view = JavaFX::ImageView.new(@image))
		@image_view.setFocusTraversable true
		setFocusTraversable false
		# setOnMouseClicked lambda { |event| event.getSource.select :single }
	end

	def selected?
		@isSelected
	end
	
	def select(id = :single)
		getChildren.add @select = JavaFX::ImageView.new(resource_url(:images, "select-#{@@select_images[id]}.png").to_s) unless selected?
		@isSelected = true
		self
	end

	def deselect
		getChildren.remove @select if selected?
		@isSelected = false
		self
	end
end
