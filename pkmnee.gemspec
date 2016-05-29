Gem::Specification.new do |s|
	s.name						= "Pokemon Essentials Editor"
	s.version					= "0.0.1"
	s.license					= "GPL v3"
	s.summary					= "Edit dumped PKMN Essentials data files"
	s.author					= "Peter Lauck"
	s.email						= "griest024@gmail.com"
	s.homepage					= "https://github.com/griest024/PokemonEssentialsEditor"
	s.bindir					= 'bin'
	s.executables				<< 'main.rb'
	s.add_runtime_dependency	'jrubyfx'
	s.add_runtime_dependency	'require_all'
end