dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/dependency_injector")
require File.expand_path("#{dir}/../../lib/geminstaller/config_builder")

context "a config builder" do
  setup do
  end

  specify "should successfully assemble an application object" do
    dependency_injector = GemInstaller::DependencyInjector.new
    test_config_file_path = File.expand_path("#{dir}/test_geminstaller_config.yml")
    dependency_injector.config_file_path = test_config_file_path
    config_builder = dependency_injector.registry.config_builder
    config = config_builder.build_config
    config.gems[0].name.should_equal("testgem1")
  end
end
