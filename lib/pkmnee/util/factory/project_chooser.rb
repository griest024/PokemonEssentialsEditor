
module PKMNEE::Util::Factory

	def self.projectChooser
		ret = JavaFX::FileChooser.new
		ret.setTitle "Open a Pokemon Project"
		ret.getExtensionFilters.add ret.class::ExtensionFilter.new("Pokemon Projects", "*.pkproj")
		ret
	end
end
