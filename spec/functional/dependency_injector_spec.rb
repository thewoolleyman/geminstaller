dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "Dependency Injector" do
  setup do
  end

  specify "should successfully assemble an application object" do
    dependency_injector = GemInstaller::DependencyInjector.new
    test_config_file_path = File.expand_path("#{dir}/test_geminstaller_config.yml")
    dependency_injector.config_file_path = test_config_file_path
    application = dependency_injector.registry.app
    application.should_not_be_nil
    application.config_builder.should_not_be_nil
    application.gem_command_manager.should_not_be_nil
    application.output_proxy.should_not_be_nil
  end
end
