# This is a test of the GemInstaller autogem functionality

dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_utils")
require File.expand_path("#{dir}/../helper/test_gem_home")
require File.expand_path("#{dir}/smoketest_support")

module GemInstaller
  class AutoGemTest
    include GemInstaller::SpecUtils::ClassMethods
    include GemInstaller::SmoketestSupport

    def run()
      GemInstaller::TestGemHome.put_rubygems_on_load_path
      dir = File.dirname(__FILE__)
      use_sudo = true

      # heckle -> hoe -> rubyforge show a three-level dependency
      required_gems = [
        'ruby-doom-0.8', 
        'rutils-0.1.3', 
        'x10-cm17a-1.0.1', 
        'heckle-1.0.0',
        'hoe', 
        'rubyforge']

      dir = File.dirname(__FILE__)
      config_files = "#{File.join(dir,'smoketest-geminstaller.yml')},#{File.join(dir,'smoketest-geminstaller-override.yml')}"
      geminstaller_cmd = "#{gem_home} #{ruby_cmd} #{geminstaller_executable} --config=#{config_files}"
      print "Running geminstaller: #{geminstaller_cmd}\n"
      print "We won't verify installation, run smoketest.rb for that...\n"
      print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
      IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
      print "\n\n"

      print "Geminstaller command complete.  Now testing GemInstaller.autogem() command.\n"

      remove_geminstaller_from_require_array
      $:.unshift("#{geminstaller_lib_dir}")
      require "geminstaller"

      no_autogem_regexp = 'x10-cm17a'
      if GemInstaller::RubyGemsVersionChecker.matches?('< 0.9')
        # ruby-doom fails with require-gem on rubygems 0.8
        no_autogem_regexp += "|ruby-doom"
      end
      no_autogem = /#{no_autogem_regexp}/
      
      not_toplevel = /(hoe|rubyforge)/

      old_gem_home = Gem.dir
      Gem.clear_paths
      ENV['GEM_HOME'] = gem_home_dir
      begin
        loaded_gems = GemInstaller::autogem("--config=#{config_files}")
      ensure
        Gem.clear_paths
        ENV['GEM_HOME'] = old_gem_home
      end
      print "These gems were loaded, verifying they are complete:\n"
      print loaded_gems.map {|g| g.name }.join("\n")
      print "\n"
      
      required_gems.each do |required_gem|
        found, skip = nil
        loaded_gems.each do | loaded_gem|
          found = required_gem =~ /#{loaded_gem.name}/
          break if found
          skip = true if required_gem =~ no_autogem
          skip = true if required_gem =~ not_toplevel
        end
        unless found || skip
          print "FAILURE, GemInstaller.autogem did not return the expected gem #{required_gem}, gems were:\n"
          loaded_gems.each do |loaded_gem|
            print "#{loaded_gem.name}\n"
          end
          raise
        end
      end

      required_gems.each do |required_gem|
        found, skip = nil
        $:.each do |path_element|
          found = path_element =~ /#{required_gem}/
          break if found
          skip = true if required_gem =~ no_autogem
        end
        unless found || skip
          print "FAILURE, GemInstaller.autogem did not put required gem #{required_gem} on load path: #{$:}" 
          raise
        end
      end

      $:.each do |path_element|
        raise "gem with no_autogem #{no_autogem} should not be in load path: #{$:}" if path_element =~ /#{no_autogem}/
      end

      print "\n\n"
      print "SUCCESS! FANFARE! All gems were successfully added to the load path, except the one that shouldn't be!\n\n"
      return true
    end
  end
end

require 'test/unit'

module GemInstaller
  class AutoGemSmokeTest < Test::Unit::TestCase
    def test_autogem
      assert(GemInstaller::AutoGemTest.new.run, "FAILURE, autogem smoketest failed.") 
    end
  end
end
