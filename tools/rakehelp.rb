def setup_tests
  Rake::TestTask.new do |t|
    t.libs << "test"
    t.test_files = FileList['test/test*.rb']
    t.verbose = true
  end
end


def setup_clean otherfiles
  files = ['**/*.log'] + otherfiles
  CLEAN.include(files)
end


def setup_rdoc files
  Rake::RDocTask.new do |rdoc|
    rdoc.rdoc_dir = 'doc/rdoc'
    rdoc.options << '--line-numbers'
    rdoc.rdoc_files.add(files)
  end
end


def base_gem_spec(pkg_name, pkg_version)
  rm_rf "test/coverage"
  pkg_version = pkg_version
  pkg_name    = pkg_name
  pkg_file_name = "#{pkg_name}-#{pkg_version}"
  Gem::Specification.new do |s|
    s.name = pkg_name
    s.version = pkg_version
    s.platform = Gem::Platform::RUBY
    s.has_rdoc = true
    s.extra_rdoc_files = [ "README" ]

    s.files = %w(COPYING LICENSE README Rakefile) +
      Dir.glob("{bin,doc/rdoc,test}/**/*") + 
      Dir.glob("{examples,tools,lib}/**/*.rb")

    s.require_path = "lib"
    s.bindir = "bin"
  end
end

def setup_gem(pkg_name, pkg_version)
  spec = base_gem_spec(pkg_name, pkg_version)
  yield spec if block_given?

  Rake::GemPackageTask.new(spec) do |p|
    p.gem_spec = spec
    p.need_tar = true if RUBY_PLATFORM !~ /mswin/
  end
end

def sub_project(project, *targets)
  targets.each do |target|
    Dir.chdir "projects/#{project}" do
      sh %{rake --trace #{target.to_s} }
    end
  end
end

# Conditional require rcov/rcovtask if present
begin
  require 'rcov/rcovtask'
  
  Rcov::RcovTask.new do |t|
    t.test_files = FileList['test/test*.rb']
    t.rcov_opts << "-x /usr"
    t.output_dir = "test/coverage"
  end
rescue Object
end
