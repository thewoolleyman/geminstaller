# This is a test of the GemInstaller autogem functionality

# It requires that the GemInstaller gem be installed

dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_utils")
require File.expand_path("#{dir}/../helper/test_gem_home")

module GemInstaller
  class AutoGemTest
    include GemInstaller::SpecUtils::ClassMethods

    def run(no_warnings = false)
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

      is_windows = RUBY_PLATFORM =~ /mswin/ ? true : false

      print "Important Note: Before running this, you should make sure you do not have the current geminstaller gem installed locally.  Use rake uninstall_gem to uninstall it.\n\n"
      print "This will install the following gems and verify they can be autoloaded with geminstaller the autoload command.\n"
      unless no_warnings
        print "If that is OK, press 'y'\n\n"
        required_gems.each {|gem| print "  " + gem + "\n"}
        response = gets
        exit unless response.index('y')
      end

      sudo = '' 
      sudo = '--sudo' unless is_windows

      dir = File.dirname(__FILE__)
      config_files = "#{File.join(dir,'smoketest-geminstaller.yml')},#{File.join(dir,'smoketest-geminstaller-override.yml')}"
      path_to_app = File.expand_path("#{dir}/../../bin/geminstaller")
      geminstaller_cmd = "#{ruby_cmd} #{path_to_app} #{sudo} --config=#{config_files}"
      print "Running geminstaller: #{geminstaller_cmd}\n"
      print "We won't verify installation, run smoketest.rb for that...\n"
      print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
      IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
      print "\n\n"

      print "Geminstaller command complete.  Now testing GemInstaller.autogem() command.\n"
      require File.expand_path("#{dir}/../../lib/geminstaller")
      require 'pp'

      no_autogem_regexp = 'x10-cm17a'
      if GemInstaller::RubyGemsVersionChecker.matches?('< 0.9')
        # ruby-doom fails with require-gem on rubygems 0.8
        no_autogem_regexp += "|ruby-doom"
      end
      no_autogem = /#{no_autogem_regexp}/
      
      not_toplevel = /(hoe|rubyforge)/

      loaded_gems = GemInstaller::autogem("--config=#{config_files}")
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
          exit 1
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
          exit 1
        end
      end

      $:.each do |path_element|
        raise "gem with no_autogem #{no_autogem} should not be in load path: #{$:}" if path_element =~ /#{no_autogem}/
      end

      print "\n\n"
      print "SUCCESS! FANFARE! All gems were successfully added to the load path, except the one that shouldn't be!\n\n"
    end
  end
end

no_warnings = (ARGV.member?('--no-warnings') ? true: false)
GemInstaller::AutoGemTest.new.run(no_warnings)