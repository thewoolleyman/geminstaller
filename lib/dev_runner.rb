dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller.rb")

# Run this file via Ruby from the "lib" dir to test the app without installing the gem
GemInstaller.run
