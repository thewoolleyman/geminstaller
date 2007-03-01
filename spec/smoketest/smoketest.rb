# This is a quick smoke test, using smoketest-geminstaller.yml and smoketest-geminstaller-override.yml.

# It verifies that geminstaller works as expected in a production-like environment, using 
# real gems against the real rubyforge.org.  For now, it purposely relies on visual inspection,
# rather than trying to capture and interpret stdout. 

# It's not part of the real test suite because I don't want to include dependencies on rubyforge or real gems
# in the test suite.  It's mostly to find bugs that I can then expose with targeted specs in the real suite

# It obviously requires that you have a network connection. It will uninstall some gems 
# and then reinstall them via geminstaller.  If you actually need one of these gems it will probably screw them
# up, forcing you to manually fix them.  If you don't want that to happen, don't run it

# Run this file as sudo if that is required in order for you to successfully install gems
# (or change the ownership/permissions of your gems installation to the current user)

use_sudo = true
test_gems = ['ruby-doom', 'rutils', 'x10-cm17a']

print "Important Note: Before running this, you should make sure you don't have the geminstaller gem installed locally.  Otherwise, you could run the installed version rather than the version in your working copy.\n\n"
print "This will uninstall the following gems and reinstall them with geminstaller.  If you don't want that to happen, kill it now (oops it's too late, you should have read the comments first!)\n\n"
test_gems.each {|gem| print "  " + gem + "\n"}

is_windows = RUBY_PLATFORM.index('mswin') == 'i386-mswin32' ? true : false

use_sudo = false
gem_cmd = is_windows ? 'gem.bat' : 'gem'
sudo = ''
unless is_windows
  print "Enter y if you need to use sudo to install/uninstall gems, anything else to not use sudo:\n"
  response = gets
  use_sudo = true if response.index('y')
  if use_sudo
    print "Enter your sudo password (if required),\n"
    sudo_init = IO.popen("sudo pwd")
    sudo_init.gets
    sudo = 'sudo'
  end
end
test_gems.each do |gem|
  print "Uninstalling all versions of #{gem}.  This will give an error if it's not already installed.\n"
  IO.popen("#{sudo} #{gem_cmd} uninstall -a #{gem}") {|process| process.readlines.each {|line| print line}}
end

print "\n\n"
dir = File.dirname(__FILE__)
path_to_app = File.expand_path("#{dir}/../../bin/geminstaller")
sudo_flag = ''
sudo_flag = '--sudo' if use_sudo
geminstaller_cmd = "ruby #{path_to_app} #{sudo_flag} --info --verbose --config=#{File.join(dir,'smoketest-geminstaller.yml')},#{File.join(dir,'smoketest-geminstaller-override.yml')}"
print "Running geminstaller: #{geminstaller_cmd}\n"
print "This should print a message for each of the gems which are installed.\n"
print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
print "\n\n"

print "Geminstaller command complete.  Now we'll run gem list to visually check that the gems listed above were actually installed locally.\n"
test_gems.each do |gem|
  print "\nRunning gem list for #{gem}, verify that it contains the expected version(s)"
  # TODO: we could make this into a real test and avoid visual inspection by parsing and checking the output, then failing if we don't get the expected output. 
  IO.popen("#{gem_cmd} list #{gem}") {|process| process.readlines.each {|line| print line}}
end
