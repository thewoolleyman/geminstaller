# -*- ruby -*-

require 'rubygems'
begin
  gem 'hoe', '= 1.8.3' # Hoe F#@%ed everything up >= 1.11.0, force old version 'til I can rip out dependencies on it
  require 'hoe'
rescue LoadError
  abort "ERROR: GemInstaller has build- and test-time dependencies
       on Hoe and other libraries.  Run the 'geminstaller'
       executable from the root of the geminstaller source
       tree, and GemInstaller will automatically install
       these dependencies."
end

require './lib/geminstaller.rb'
require './lib/geminstaller/hoe_extensions.rb'

IndependentHoe.new('geminstaller', GemInstaller.version) do |p|
  p.author = 'Chad Woolley'
  p.email = 'thewoolleyman@gmail.com'
  p.rubyforge_name = 'geminstaller'
  p.summary = p.paragraphs_of('README.txt', 1).first.split(/\n/)[2]
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.clean_globs << 'coverage'
  p.clean_globs << 'website/out'
  p.clean_globs << 'website/output'
  p.clean_globs << '**/webgen.cache'
  p.extra_deps = []
end

def run_smoketest(path_to_smoketest)
  cmd = "#{Hoe::RUBY_FLAGS} #{path_to_smoketest} #{Hoe::FILTER}"
  result = send :ruby, cmd
  raise "#{path_to_smoketest} Smoketest failed" unless result == 0 || result == true
end

desc "Run all metrics"
task :metrics do
  Rake::Task[:coverage].invoke
  Rake::Task[:audit].invoke
end

task :coverage do
  rm_rf "coverage"
  rm_rf "website/out/code/coverage"
  sh "mkdir -p website/out/code"
  sh "rcov -o website/out/code/coverage test/test_all.rb"
end

task :coverage_no_fail do
  begin
    Rake::Task[:coverage].invoke
  rescue
  end
end

desc "Diff the manifest"
task :diff_manifest => :clean do
  f = "Manifest.tmp"
  require 'find'
  files = []
  Find.find '.' do |path|
    next unless File.file? path
    next if path =~ /\.svn|tmp$|CVS/
    next if path =~ /\.iml|\.ipr|\.iws|\.kpf|\.tmproj|\.project/
    next if path =~ /\.\/nbproject/
    next if path =~ /\.\/spec/
    next if path =~ /\.\/pkg/
    next if path =~ /\.\/out/
    next if path =~ /\.\/website\/out/
    files << path[2..-1]
  end
  files = files.sort.join "\n"
  File.open f, 'w' do |fp| fp.puts files end
  system "diff -du Manifest.txt #{f}"
  rm f
end

desc "Update the manifest"
task :update_manifest do
  system('rake diff_manifest | patch -p0 Manifest.txt')
end

desc "Run Webgen to generate website"
task :webgen do
  # rm_rf "website/out"
  rm_rf "website/webgen.cache"
  # Use webgen/RedCloth versions from GemInstaller config
  # require 'geminstaller'
  # GemInstaller.autogem
  # ARGV.clear
  # ARGV.concat(['-d','website'])
  # load 'webgen'
  sh 'webgen -d website'
end

desc "Move ri docs to website"
task :website_rdocs => :docs do
  rm_rf "website/out/code/rdoc"
  sh "mkdir -p website/out/code/"
  mv "doc", "website/out/code/rdoc"
end

desc "Generate website, including rdoc and coverage"
task :website => [:webgen, :website_rdocs, :coverage] do
end

desc 'Publish website to RubyForge'
task :publish_website => [:clean, :website, :upload_website] do
end

desc 'Publish website to RubyForge even if test coverage run rails'
task :publish_website_no_fail => [:clean, :webgen, :website_rdocs, :coverage_no_fail, :upload_website] do
end

desc 'Upload website (should already be clean and generated)'
task :upload_website do
  host = "thewoolleyman@rubyforge.org"
  remote_dir = "/var/www/gforge-projects/geminstaller"
  local_dir = 'website/out'
  sh %{rsync -av --delete --exclude=statsvn #{local_dir}/ #{host}:#{remote_dir}}
end

desc 'Run All Smoketests'
task :all_smoketest => [:clean] do
  run_smoketest 'test/test_all_smoketests.rb'
end

desc 'Run Install Smoketest'
task :install_smoketest => [:clean] do
  run_smoketest 'spec/smoketest/install_smoketest.rb'
end

desc 'Run AutoGem Smoketest'
task :autogem_smoketest => [:clean] do
  run_smoketest 'spec/smoketest/autogem_smoketest.rb'
end

desc 'Run Rails Smoketest'
task :rails_smoketest => [:clean] do
  run_smoketest 'spec/smoketest/rails_smoketest.rb'
end

desc 'Run Debug Smoketest'
task :debug_smoketest => [:clean] do
  run_smoketest 'spec/smoketest/debug_smoketest.rb'
end

desc 'CruiseControl.rb default task'
task :cruise do
  if File.exist?(File.dirname(__FILE__) + "/.git")
    sh "git submodule init"
    sh "git submodule update"
  end
  Rake::Task[:default].invoke
end

# vim: syntax=Ruby
