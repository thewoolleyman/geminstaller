# This is a test of the GemInstaller autogem functionality

# It requires that the GemInstaller gem be installed

use_sudo = true

# heckle -> hoe -> rubyforge show a three-level dependency
required_gems = [
  'ruby-doom-0.8', 
  'rutils-0.1.3', 
  'rutils-0.1.9', 
  'x10-cm17a-1.0.1', 
  'heckle-1.0.0', 
  'hoe', 
  'rubyforge']

no_autogem = 'heckle'

is_windows = RUBY_PLATFORM =~ /mswin/ ? true : false

print "Important Note: Before running this, you should make sure you DO have the current geminstaller gem installed locally.  Use rake install_gem to install it.\n\n"
print "This will install the following gems and verify they can be autoloaded with geminstaller the autoload command.  If that is OK, press 'y'\n\n"
required_gems.each {|gem| print "  " + gem + "\n"}
response = gets
exit unless response.index('y')

sudo = '' 
sudo = '--sudo' unless is_windows

dir = File.dirname(__FILE__)
config_files = "#{File.join(dir,'smoketest-geminstaller.yml')},#{File.join(dir,'smoketest-geminstaller-override.yml')}"
geminstaller_exec = 'geminstaller'
geminstaller_exec += '.cmd' if is_windows
geminstaller_cmd = "#{geminstaller_exec} #{sudo} --config=#{config_files}"
print "Running geminstaller: #{geminstaller_cmd}\n"
print "We won't verify installation, run smoketest.rb for that...\n"
print "Please be patient, it may take a bit, or may not work at all if rubyforge or your network connection is down, or you don't have proper permissions, or if there's a bug in geminstaller :)\n\n"
IO.popen(geminstaller_cmd) {|process| process.readlines.each {|line| print line}}
print "\n\n"

print "Geminstaller command complete.  Now testing GemInstaller.autogem() command.\n"
require 'rubygems'
require 'geminstaller'
begin
  GemInstaller::autogem("#{config_files}")
rescue Exception => e
  # ruby-doom fails with require-gem on rubygems 0.8
  if Gem::RubyGemsVersion.index('0.8') == 0
    raise e unless e.message.index('ruby-doom')
  else
    raise e
  end
end

required_gems.each do |gem|
  found = nil
  $:.each do |path_element|
    found = path_element =~ /gem/
    break if found
    break if path_element =~ /#{no_autogem}/
  end
  raise "required gem #{gem} not found in load path: #{$:}" unless found
end

$:.each do |path_element|
  raise "gem with no_autogem #{no_autogem} should not be in load path: #{$:}" if path_element =~ /#{no_autogem}/
end

print "\n\n"
print "SUCCESS! FANFARE! All gems were successfully added to the load path, except the one that shouldn't be!\n\n"
