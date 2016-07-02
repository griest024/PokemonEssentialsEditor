
module PKMNEE::Import
	
	def self.autotiles(verbose = true)
		puts "\nImporting autotiles..."
		autotiles = {}
		safe_mkdir "#{$project_dir}/res/autotile", "#{$project_dir}/data/autotile", "#{$project_dir}/res/autotile/blank"
		JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::Image.new(resource_url(:images, "autotile_blank.png").to_s), nil), "png", Java::File.new("#{$rmxp_dir}/Graphics/Autotiles/Blank.png"))
		Dir["#{$rmxp_dir}/Graphics/Autotiles/*"].each.with_index 1 do |file, i|
			tiles = []
			autotile = []
			id = (name = File.basename(file, ".*")).force_encoding("UTF-8").to_id
			puts "#{i}:	#{id}" if verbose
			safe_mkdir "#{$project_dir}/res/autotile/#{id}", "#{$project_dir}/data/autotile/#{id}"
			img = JavaFX::Image.new(resource_url(:graphics, "Autotiles/#{name}.png").to_s)
			reader = img.getPixelReader
			if img.getHeight == 128
				8.times do |y|
					6.times do |x|
						autotile << JavaFX::WritableImage.new(reader, x*16, y*16, 16, 16)
					end
				end
				$autotile_def.each.with_index do |a, i|
					auto_image = JavaFX::WritableImage.new(32, 32)
					writer = auto_image.getPixelWriter
					writer.setPixels(0, 0, 16, 16, autotile[a[0]].getPixelReader, 0, 0)
					writer.setPixels(16, 0, 16, 16, autotile[a[1]].getPixelReader, 0, 0)
					writer.setPixels(0, 16, 16, 16, autotile[a[2]].getPixelReader, 0, 0)
					writer.setPixels(16, 16, 16, 16, autotile[a[3]].getPixelReader, 0, 0)
					image_path = "#{id}/#{i}.png".force_encoding("UTF-8")
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(auto_image, nil), "png", Java::File.new("#{$project_dir}/res/autotile/#{image_path}"))
					tiles << PKMNEE::Util::AutotileImageWrapper.new(image_path)
				end
			else
				48.times do |n|
					image_path = "#{id}/#{n}.png".force_encoding("UTF-8")
					JavaX::ImageIO.write(JavaFX::SwingFXUtils.fromFXImage(JavaFX::WritableImage.new(reader, 0, 0, 32, 32), nil), "png", Java::File.new("#{$project_dir}/res/autotile/#{image_path}"))
					tiles << PKMNEE::Util::AutotileImageWrapper.new(image_path)
				end
			end
			autotiles[id] = tiles
		end
		autotiles
	end
end
