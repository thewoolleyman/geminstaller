Gem::Specification.new do |s|
  s.name = %q{dependent-stubgem-multilevel}
  s.version = "1.0.0"
  s.date = %q{2007-03-18}
  s.summary = %q{Dependent stub gem for testing geminstaller}
  s.email = %q{geminstaller@rubyforge.org}
  s.homepage = %q{    by Chad Woolley}
  s.rubyforge_project = %q{dependent-stubgem-multilevel}
  s.description = %q{== FEATURES/PROBLEMS:  * This dependent stub gem is embedded in the geminstaller project to allow testing scenarios with gem dependencies  == SYNOPSYS:  Allows geminstaller tests to install/uninstall gems without depending on real gems.  == REQUIREMENTS:}
  s.has_rdoc = true
  s.authors = ["Chad Woolley"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/dependent_stubgem_multilevel.rb", "test/test_dependent_stubgem_multilevel.rb"]
  s.test_files = ["test/test_dependent_stubgem_multilevel.rb"]
  s.add_dependency(%q<dependent-stubgem>, [">= 1.0.0"])
end
