dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller/requires.rb")

module GemInstaller
  def self.run(args = [])
    app = create_application(args)
    app.run
  end 
  
  def self.autogem(config_paths=nil)
    args = []
    args = ["--config=#{config_paths}"] if config_paths
    app = create_application(args)
    app.autogem
  end

  def self.version
    "0.0.1"
  end

  def self.create_application(args = [], registry = nil)
    registry ||= create_registry
    app = registry.app
    app.args = args
    app
  end
  
  def self.create_registry
    dependency_injector = GemInstaller::DependencyInjector.new
    dependency_injector.registry
  end
end