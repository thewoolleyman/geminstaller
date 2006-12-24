dir = File.dirname(__FILE__)

require 'test/unit'
require File.expand_path("#{dir}/../spec/spec_helper")

@@test_files = Dir.glob("#{dir}/../spec/**/*_spec.rb")
@@test_files.each {|x| require File.expand_path(x)}

class TestSuite
  def self.suite
    suite = Test::Unit::TestSuite.new
    return suite
  end
end

result = Test::Unit::AutoRunner.run
exit result
