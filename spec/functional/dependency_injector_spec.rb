dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "Dependency Injector" do
  setup do
  end

  specify "should successfully assemble an application object" do
    dependency_injector = GemInstaller::DependencyInjector.new
    application = dependency_injector.registry.app
    application.should_not_be_nil
    application.config_builder.should_not_be_nil
    application.gem_command_manager.should_not_be_nil
    application.output_proxy.should_not_be_nil
    application.arg_parser.should_not_be_nil
  end
end
