dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")
require 'test/unit'

module GemInstaller
  class RailsTest < Test::Unit::TestCase
    def test_rails_app_with_geminstaller
      result = system("#{ruby_cmd} -I #{File.dirname(__FILE__)}/../../lib -Cspec/fixture/sample_rails_app test/functional/sample_controller_test.rb")
    
      assert(result,
            "FAILURE, tests for geminstaller sample rails app failed.") 
    end
  end
end