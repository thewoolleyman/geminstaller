# -*- ruby -*-

require File.expand_path("#{File.dirname(__FILE__)}/spec/helper/test_gem_home")
GemInstaller::TestGemHome.install_rubygems

begin
  require 'hoe'
rescue LoadError => e
  puts e
  abort "ERROR: GemInstaller has build- and test-time dependencies
       on Hoe and other libraries.  Run the 'geminstaller'
       executable from the root of the geminstaller source
       tree, and GemInstaller will automatically install
       these dependencies."
end

puts "Gem::RubyGemsVersion = #{Gem::RubyGemsVersion}"
require './lib/geminstaller.rb'
require './lib/geminstaller/hoe_extensions.rb'

IndependentHoe.plugin :seattlerb

IndependentHoe.spec 'geminstaller' do |p|
  developer 'Chad Woolley', 'thewoolleyman@gmail.com'
  p.rubyforge_name = 'geminstaller'
  p.version = GemInstaller.version
  p.summary = "See http://geminstaller.rubyforge.org"
  clean_globs << 'coverage'
  clean_globs << 'website/out'
  clean_globs << 'website/output'
  clean_globs << '**/webgen.cache'
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
  sh "rcov -o website/out/code/coverage test_suites/test_all.rb"
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
    next if path =~ /\.git|\.gitmodules/
    next if path =~ /dummyrepo/
    next if path =~ /\.iml|\.ipr|\.iws|\.kpf|\.tmproj|\.project/
    next if path =~ /\.idea/
    next if path =~ /tmtags/
    next if path =~ /\.\/nbproject/
    next if path =~ /\.\/spec/
    next if path =~ /\.\/test_suites/
    next if path =~ /\.\/pkg/
    next if path =~ /\.\/out/
    next if path =~ /\.\/website\/out/
    next if path =~ /\.DS_Store/
    next if path =~ /\.rvmrc/
    next if path =~ /Gemfile/
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
task :all_smoketest => [:git_submodule_update, :clean] do
  run_smoketest 'test_suites/test_all_smoketests.rb'
end

desc 'Run Install Smoketest'
task :install_smoketest => [:git_submodule_update, :clean] do
  run_smoketest 'spec/smoketest/install_smoketest.rb'
end

desc 'Run AutoGem Smoketest'
task :autogem_smoketest => [:git_submodule_update, :clean] do
  run_smoketest 'spec/smoketest/autogem_smoketest.rb'
end

desc 'Run Rails Smoketest'
task :rails_smoketest => [:git_submodule_update, :clean] do
  run_smoketest 'spec/smoketest/rails_smoketest.rb'
end

desc 'Run Debug Smoketest'
task :debug_smoketest => [:git_submodule_update, :clean] do
  run_smoketest 'spec/smoketest/debug_smoketest.rb'
end

desc 'CruiseControl.rb default task'
task :cruise => [:geminstaller, :git_submodule_commit_and_push] do
  Rake::Task[:default].invoke
end

desc 'Run GemInstaller to install development dependencies'
task :geminstaller do
  system('geminstaller') || raise("'geminstaller' command failed")
end

desc 'Git submodules init and update'
task :git_submodule_update do
  if File.exist?(File.dirname(__FILE__) + "/.git")
    # NOTE: If you remove a submodule, you must do 'git rm --cached [path to deleted submodule]' or else you will get warnings
    sh "git submodule init"
    sh "git submodule update"
  end
end

# TODO: make these use submodule foreach option
desc 'Git submodules init, update, and pull'
task :git_submodule_pull => [:git_submodule_update] do
  if File.exist?(File.dirname(__FILE__) + "/.git")
    sh "cd dummyrepo && git pull origin master && git status; cd .."
    sh "cd spec/fixture/rubygems_dist/rubygems-trunk/ && git pull origin master && git status; cd ../../../../"
  end
end

# TODO: make these use submodule foreach option
desc 'Git submodules init, update, pull, commit, and push - warning - does a commit and push to remote repo'
task :git_submodule_commit_and_push => [:git_submodule_pull] do
  if File.exist?(File.dirname(__FILE__) + "/.git") && git_repo_writeable?
    puts "Updating, committing, and pushing git submodule updates..."
    git_commit_submodule_commit('dummyrepo')
    git_commit_submodule_commit('spec/fixture/rubygems_dist/rubygems-trunk')
    sh "git push"
  end
end

def git_commit_submodule_commit(submodule_path)
  sh "git commit #{submodule_path} -m 'update #{submodule_path} submodule'" do |ok, res|
    if !ok and res.exitstatus != 1
      puts "pattern not found (status = #{res.exitstatus})"
      raise "git #{submodule_path} submodule commit failed"
    end
  end
end

def git_repo_writeable?
  `git config --get-regexp remote\..+\.url` =~ /git@/
end

# vim: syntax=Ruby
