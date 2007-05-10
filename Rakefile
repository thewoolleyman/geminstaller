# -*- ruby -*-

require 'rubygems'
begin
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
  p.rubyforge_name = 'geminstaller'
  p.summary = p.paragraphs_of('README.txt', 1).first.split(/\n/)[2]
  p.description = p.paragraphs_of('README.txt', 2..5).join("\n\n")
  p.url = p.paragraphs_of('README.txt', 0).first.split(/\n/)[1..-1]
  p.changes = p.paragraphs_of('History.txt', 0..1).join("\n\n")
  p.clean_globs << 'coverage'
  p.extra_deps = []
end

desc "Run all metrics"
task :metrics do
  Rake::Task[:coverage].invoke
  Rake::Task[:audit].invoke
end

task :coverage do
  rm_rf "coverage"
  sh "rcov test/test_all.rb"
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
    next if path =~ /\.\/spec/
    next if path =~ /\.\/pkg/
    next if path =~ /\.\/output/
    next if path =~ /\.\/website\/output/
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

require 'rake'
require 'spec/rake/spectask'

desc "Run all specs"
task :all_specs do
end

# vim: syntax=Ruby
