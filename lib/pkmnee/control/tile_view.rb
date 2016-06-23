
class PKMNEE::Control::TileView < JavaFX::StackPane

	attr_accessor :tile, :image, :isSelected

	@@select_images = {:single => "single", :left => "left-edge", :right => "right-edge", :top => "top-edge", :bottom => "bottom-edge", :ne => "ne-corner", :nw => "nw-corner", :se => "se-corner", :sw => "sw-corner", :no_right => "right-missing", :no_left => "left-missing", :no_top => "top-missing", :no_bottom => "bottom-missing", :ver => "vertical", :hor => "horizontal"}

	def initialize(tile)
		@tile = tile
		@image = @tile.getImage
		super(@image_view = JavaFX::ImageView.new(@image))
		@image_view.setFocusTraversable true
		setFocusTraversable false
	end

	def selected?
		@isSelected
	end
	
	def select(id = :single)
		getChildren.setAll @image_view, JavaFX::ImageView.new(resource_url(:images, "select-#{@@select_images[id]}.png").to_s)
		@isSelected = true
		self
	end

	def deselect
		getChildren.setAll @image_view
		@isSelected = false
		self
	end
end
