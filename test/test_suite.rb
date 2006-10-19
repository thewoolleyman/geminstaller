require 'test/unit'

dir = File.dirname(__FILE__)
@@test_files = Dir.glob("#{dir}/../spec/**/*_spec.rb")
@@test_files.each {|x| require File.expand_path(x)}

exit 0
