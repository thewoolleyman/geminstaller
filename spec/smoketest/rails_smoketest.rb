dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_utils")
require File.expand_path("#{dir}/smoketest_support")
require 'test/unit'

module GemInstaller
  class RailsSmokeTest < Test::Unit::TestCase
    include GemInstaller::SpecUtils::ClassMethods
    include GemInstaller::SmoketestSupport

    def test_rails_app_with_geminstaller
      remove_gem_home_dir
      
      result = system("#{gem_home} #{ruby_cmd} -I #{File.expand_path(File.dirname(__FILE__) + '/../../lib')} -Cspec/fixture/sample_rails_app test/functional/sample_controller_test.rb")
    
      assert(result,
            "FAILURE, tests for geminstaller sample rails app failed.") 
    end
  end
end