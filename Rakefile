require 'rake'
require 'rake/testtask'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'tools/rakehelp'
require 'fileutils'
include FileUtils

setup_tests
setup_clean ["pkg", "lib/*.bundle", "*.gem", "doc/site/output", ".config"]

setup_rdoc ['README', 'LICENSE', 'COPYING', 'lib/**/*.rb', 'doc/**/*.rdoc']

desc "Does a full test run"
task :default => [:test]

task :package => [:clean,:test,:rerdoc]

task :site_webgen do
  sh %{pushd doc/site; webgen; scp -r output/* #{ENV['SSH_USER']}@rubyforge.org:/var/www/gforge-projects/geminstaller/; popd }
end

task :site_rdoc do
  sh %{ scp -r doc/rdoc/* #{ENV['SSH_USER']}@rubyforge.org:/var/www/gforge-projects/geminstaller/rdoc/ }
end

task :site_coverage => [:rcov] do
  sh %{ scp -r test/coverage/* #{ENV['SSH_USER']}@rubyforge.org:/var/www/gforge-projects/geminstaller/coverage/ }
end

task :site => [:site_webgen, :site_rdoc, :site_coverage]

name="geminstaller"
version="0.2.0"

setup_gem(name, version) do |spec|
  spec.summary = "This is a little tool which will automatically perform 'gem install' of all required gem versions for a Ruby project, based on a YAML config file."
  spec.description = spec.summary
  spec.test_files = Dir.glob('test/test_suite.rb')
  spec.author="Chad Woolley"
  spec.executables=['geminstaller']
  spec.files += %w(README Rakefile)

  spec.required_ruby_version = '>= 1.8.2'
  
  spec.add_dependency('needle', '>= 1.3.0')
end

task :install do
  sh %{rake package}
  sh %{gem install pkg/geminstaller-#{version}}
end

task :uninstall => [:clean] do
  sh %{gem uninstall geminstaller}
end


task :gem_source do
  mkdir_p "pkg/gems"
 
  FileList["**/*.gem"].each { |gem| mv gem, "pkg/gems" }
  FileList["pkg/*.tgz"].each {|tgz| rm tgz }
  rm_rf "pkg/#{name}-#{version}"

  sh %{ generate_yaml_index.rb -d pkg }
  sh %{ scp -r pkg/* #{ENV['SSH_USER']}@rubyforge.org:/var/www/gforge-projects/geminstaller/releases/ }
end
