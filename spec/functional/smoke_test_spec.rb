dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/dependency_injector")

context "Placeholder for real functional tests" do
  setup do
  end

  specify "should placehold" do
    application = GemInstaller::DependencyInjector.new.create_application
    application.run
  end
end
