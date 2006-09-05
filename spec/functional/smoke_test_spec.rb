dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/dependency_injector")

context "Placeholder for real functional tests" do
  setup do
  end

  specify "should placehold" do
    dependency_injector = GemInstaller::DependencyInjector.new
    test_config_file_path = File.expand_path("#{dir}/test_geminstaller_config.yml")
    dependency_injector.config_file_path = test_config_file_path
    application = dependency_injector.create_application
    application.run
  end
end
