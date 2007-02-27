Gem::Specification.new do |s|
  s.name = %q{dependent-stubgem}
  s.version = "1.0.0"
  s.date = %q{2007-02-26}
  s.summary = %q{Dependent stub gem for testing geminstaller}
  s.email = %q{dependent-stubgem@geminstaller.rubyforge.org}
  s.homepage = %q{http://geminstaller.rubyforge.org}
  s.rubyforge_project = %q{dependent-stubgem}
  s.description = %q{== FEATURES/PROBLEMS:  * This dependent stub gem is embedded in the geminstaller project to allow testing scenarios with gem dependencies  == SYNOPSYS:  Allows geminstaller tests to install/uninstall gems without depending on real gems.  == REQUIREMENTS:}
  s.default_executable = %q{dependent_stubgem}
  s.has_rdoc = true
  s.authors = ["Chad Woolley"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/dependent_stubgem", "lib/dependent_stubgem.rb", "test/test_dependent_stubgem.rb"]
  s.add_dependency(%q<stubgem>, [">= 1.0.0"])
end
