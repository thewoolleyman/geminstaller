# This is a quick smoke test, using smoketest-geminstaller.yml and smoketest-geminstaller-override.yml.

# It verifies that geminstaller works as expected in a production-like environment, using 
# real gems against the real rubyforge.org.  For now, it purposely relies on visual inspection,
# rather than trying to capture and interpret stdout. 

# It's not part of the real test suite because I don't want to include dependencies on rubyforge or real gems
# in the test suite.  It's mostly to find bugs that I can then expose with targeted specs in the real suite

# It obviously requires that you have a network connection. It will uninstall some gems 
# and then reinstall them via geminstaller.  It will override GEM_HOME (on unix only, for now) to a test location.
dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_utils")
require File.expand_path("#{dir}/smoketest_support")

module GemInstaller
  class SmokeTest
    include GemInstaller::SpecUtils::ClassMethods
    include GemInstaller::SmoketestSupport

    def run
      remove_gem_home_dir
      dir = File.dirname(__FILE__)
      # heckle -> hoe -> rubyforge show a three-level dependency
      test_gems = ['ruby-doom', 'rutils', 'x10-cm17a', 'heckle', 'hoe', 'rubyforge']
      expected_versions = {
        'ruby-doom' => ['0.8'],
        'rutils' => ['0.1.3','0.1.9'],
        'x10-cm17a' => ['1.0.1']
      }

      # verify gems are actually uninstalled before attempting to install them with GemInstaller
      test_gems.each do |gem|
        IO.popen("#{gem_home} #{gem_cmd} list #{gem}") do |process| 
          process.readlines.each do |line|
            raise RuntimeError.new("FAILURE: Test setup failed, #{gem} should not still be installed.") if line.index(gem)
          end
        end
      end

      print "\n\n"
      # inspect environment, especially LD_LIBRARY_PATH, PATH
      'env'
      geminstaller_cmd = "#{gem_home} #{ruby_cmd} #{geminstaller_executable} --config=#{File.join(dir,'smoketest-geminstaller.yml')},#{File.join(dir,'smoketest-geminstaller-override.yml')}"
      print "Running geminstaller: #{geminstaller_cmd}\n"
      print "This should print a message for each of the gems which are installed.\n"
      print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
      IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
      print "\n\n"

      print "Geminstaller command complete.  Now we'll run gem list to check that the gems listed above were actually installed locally.\n"
      success = true
      missing_gems = ''
      test_gems.each do |gem|
        # next if gem == 'x10-cm17a' # this gem sometimes fails to compile on CI box for some reason...
        print "\nRunning gem list for #{gem}, verify that it contains the expected version(s)"
        gem_found = false
        all_list_output = ''
        IO.popen("#{gem_home} #{gem_cmd} list #{gem}") do |process| 
          process.readlines.each do |line|
            print line
            all_list_output += " #{line}"
            gem_found = true if line.index(gem)
          end
        end
        unless gem_found
          success = false
          print "ERROR: #{gem} was not installed."
          missing_gems += "#{gem} "
        end
        if expected_versions[gem]
          expected_versions[gem].each do |version|
            unless all_list_output.index(version)
              success = false
              print "ERROR: Version #{version} was not installed for #{gem}"
              missing_gems += "#{gem} (#{version})"
            end
          end
        end
      end

      print "\n\n"
      if success
        print "SUCCESS! FANFARE! All gems were successfully installed!\n\n"
      else
        print "\n\nFAILURE: The following gems were not installed: #{missing_gems}\n\n"
      end

      print "\n\n"
      remove_gem_home_dir
      return success
    end
  end
end

require 'test/unit'

module GemInstaller
  class InstallSmokeTest < Test::Unit::TestCase
    def test_install
      assert(GemInstaller::SmokeTest.new.run, "FAILURE, install smoketest failed.") 
    end
  end
end
