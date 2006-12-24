dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller/requires.rb")

module GemInstaller
  def self.run(args = nil)
    application = create_application(args)
    application.run
  end
  
  def self.version
    "0.0.1"
  end

  def self.create_application(args = nil)
    registry = create_registry
    app = registry.app
    app.args = args
    app
  end
  
  def self.create_registry
    dependency_injector = GemInstaller::DependencyInjector.new
    registry = dependency_injector.registry
  end
end