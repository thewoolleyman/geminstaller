# This is a quick smoke test, using smoketest-geminstaller.yml and smoketest-geminstaller-override.yml.

# It verifies that geminstaller works as expected in a production-like environment, using 
# real gems against the real rubyforge.org.  

# It's not part of the real test suite because I don't want to include dependencies on rubyforge or real gems
# in the test suite.  It's mostly to find bugs that I can then expose with targeted specs in the real suite

# It obviously requires that you have a network connection. It will uninstall some relatively obscure gems 
# and then reinstall them via geminstaller.  If you actually need one of these gems it will probably screw them
# up, forcing you to manually fix them.  If you don't want that to happen, don't run it

# This file should be executed from the root of the geminstaller project.  Run it as sudo
# if that is required in order for you to successfully install gems (or change the ownership/permissions of your
# gems installation to the current user)

test_gems = ['rutils', 'x10-cm17a', 'ruby-doom']

p "Run this as sudo or ensure you have permissions to install gems"
p "This will uninstall and reinstall the latest versions of the following gems.  If you don't want that, to happen, kill it now (oops it's too late, you should have read the instructions first!)"
p test_gems
test_gems.each do |gem|
  p "Uninstalling all versions of #{gem}.  This will give an error if it's not already installed."
  system("sudo gem uninstall -a #{gem}")
end
geminstaller_cmd = "sudo ruby lib/dev_runner.rb --info --verbose --config=./smoketest-geminstaller.yml,./smoketest-geminstaller-override.yml"
p "Running geminstaller: #{geminstaller_cmd}"
p "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or if there's a bug in geminstaller :)"
system(geminstaller_cmd)
p "Geminstaller command complete.  Now we'll run gem list to visually check that the gems were installed"
test_gems.each do |gem|
  p "Running gem list for #{gem}, verify that it contains the expected version(s)"
  system("gem list #{gem}")
end
