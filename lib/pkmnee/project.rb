
class PKMNEE::Project

	attr_accessor :name, :author, :recent_files, :data

	def initialize(name: "Game", author: "Anonymous")
		@name = name
		@author = author
	end

	def loadData(project_dir)
		# gets all data subfolders that contain PKMN data
		Dir["#{project_dir}/data/*"].select { |dir| File.directory?(dir) && $data_classes.keys.include?(File.basename(dir).to_sym) }.each do |dir|
			type = File.basename(dir).to_sym
			data_set = PKMNEE::Util::DataSet.new($data_classes[type])
			Dir["#{dir}/*.pkmn"].each do |file| # populate the data set with all pkmn files in directory
				data_set.addData(PKMNEE::Util::DataWrapper.new($data_classes[type], file.gsub(project_dir, ''))) # gsub to get path relative to project_dir
			end
			@data[type] = data_set
		end
	end
end
