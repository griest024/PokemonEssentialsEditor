module griest::MapEditor

	def rootDir
		File.dirname(__FILE__)
	end

	def layoutDir
		rootDir + '/layout'
	end

	def resourceDir
		rootDir + '/res'
	end

	def libraryDir
		rootDir + '/lib'
	end
end