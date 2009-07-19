dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_utils")
require File.expand_path("#{dir}/smoketest_support")

module GemInstaller
  class DebugTest
    include GemInstaller::SpecUtils::ClassMethods
    include GemInstaller::SmoketestSupport

    def run
      remove_gem_home_dir
      dir = File.dirname(__FILE__)
      # heckle -> hoe -> rubyforge show a three-level dependency
      test_gems = ['x10-cm17a']
      expected_versions = {
        'x10-cm17a' => ['1.0.1']
      }

      test_gems.each do |gem|
        print "Uninstalling all versions of #{gem}.  This will give an error if it's not already installed.\n"
        cmd = "#{gem_home} #{gem_cmd} uninstall --all --ignore-dependencies --executables #{gem}"
        print "#{cmd}\n"
        IO.popen(cmd) do |process|
          process.readlines.each do |line|
            print line
          end
        end
      end

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
      geminstaller_cmd = "#{gem_home} #{ruby_cmd} #{geminstaller_executable} --config=#{File.join(dir,'debug-smoketest-geminstaller.yml')}"
      print "Running geminstaller: #{geminstaller_cmd}\n"
      print "This should print a message for each of the gems which are installed.\n"
      print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
      IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
      print "\n\n"

      print "Geminstaller command complete.  Now we'll run gem list to check that the gems listed above were actually installed locally.\n"
      success = true
      missing_gems = ''
      test_gems.each do |gem|
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

      geminstaller_cmd = "#{gem_home} #{ruby_cmd} #{geminstaller_executable} --silent --config=#{File.join(dir,'debug-smoketest-geminstaller-reinstall.yml')}"
      print "Now (re)installing the latest version of the test gems, in case this hit your real gem home and uninstalled stuff.\n"
      print "Running geminstaller: #{geminstaller_cmd}\n"
      IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
      print "\n\n"
      return success
    end
  end
end

require 'test/unit'

module GemInstaller
  class DebugSmokeTest < Test::Unit::TestCase
    def test_install
      assert(GemInstaller::DebugTest.new.run, "FAILURE, debug smoketest failed.") 
    end
  end
end
