dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "Dependency Injector" do
  before(:each) do
  end

  it "should successfully assemble an application object" do
    dependency_injector = GemInstaller::DependencyInjector.new
    application = dependency_injector.registry.app
    application.should_not be_nil
    application.config_builder.should_not be_nil
    application.install_processor.should_not be_nil
    application.output_filter.should_not be_nil
    application.arg_parser.should_not be_nil
  end
end
