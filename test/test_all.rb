dir = File.dirname(__FILE__)

require 'test/unit'
require File.expand_path("#{dir}/../spec/helper/spec_helper")

@@test_files = Dir.glob("#{dir}/../spec/**/*_spec.rb")
# put test_gem_home_spec first so we only have to perform the install once
@@test_files.unshift(Dir.glob("#{dir}/../spec/unit/test_gem_home_spec.rb")[0])
@@test_files.uniq
@@test_files.each {|x| require File.expand_path(x)}

class TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new
    return suite
  end
end

result = Test::Unit::AutoRunner.run
exit result
