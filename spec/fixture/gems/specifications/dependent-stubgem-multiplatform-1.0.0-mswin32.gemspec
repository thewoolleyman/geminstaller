Gem::Specification.new do |s|
  s.name = %q{dependent-stubgem-multiplatform}
  s.version = "1.0.0"
  s.date = %q{2007-02-28}
  s.summary = %q{Multiplatform stub gem for testing geminstaller}
  s.email = %q{ryand-ruby@zenspider.com}
  s.homepage = %q{    by Chad Woolley}
  s.rubyforge_project = %q{dependent-stubgem-multiplatform}
  s.description = %q{== FEATURES/PROBLEMS:  * This stub gem is embedded in the geminstaller project to allow testing.  == SYNOPSYS:  Allows geminstaller tests to install/uninstall gems without depending on real gems..  == REQUIREMENTS:}
  s.has_rdoc = true
  s.platform = %q{mswin32}
  s.authors = ["Chad Woolley"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "lib/dependent_stubgem_multiplatform.rb", "test/test_dependent_stubgem_multiplatform.rb"]
  s.test_files = ["test/test_dependent_stubgem_multiplatform.rb"]
  s.add_dependency(%q<stubgem-multiplatform>, [">= 1.0.0"])
end
