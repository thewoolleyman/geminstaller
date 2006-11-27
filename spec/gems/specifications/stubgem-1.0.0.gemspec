Gem::Specification.new do |s|
  s.name = %q{stubgem}
  s.version = "1.0.0"
  s.date = %q{2006-11-24}
  s.summary = %q{Ryan Davis is too lazy to write a summary}
  s.email = %q{ryand-ruby@zenspider.com}
  s.homepage = %q{http://www.zenspider.com/ZSS/Products/stubgem/}
  s.rubyforge_project = %q{stubgem}
  s.description = %q{Ryan Davis is too lazy to write a description}
  s.default_executable = %q{stubgem}
  s.has_rdoc = true
  s.authors = ["Ryan Davis"]
  s.files = ["History.txt", "Manifest.txt", "README.txt", "Rakefile", "bin/stubgem", "lib/stubgem.rb", "test/test_stubgem.rb"]
  s.test_files = ["test/test_stubgem.rb"]
  s.executables = ["stubgem"]
  s.add_dependency(%q<hoe>, [">= 1.1.4"])
end
