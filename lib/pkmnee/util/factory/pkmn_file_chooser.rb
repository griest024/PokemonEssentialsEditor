
module PKMNEE::Util::Factory

	def self.fileChooser
		ret = JavaFX::FileChooser.new
		ret.setTitle "Open Pokemon Data Files"
		ret.getExtensionFilters.add ret.class::ExtensionFilter.new("Pokemon Files", "*.pkmn")
		ret
	end
end
