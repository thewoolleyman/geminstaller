dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../spec_helper")

context "a config builder with a single config file path" do
  setup do
  end

  specify "should successfully assemble a config object" do
    test_config_file_paths = File.expand_path("#{dir}/test_geminstaller_config.yml")
    dependency_injector = GemInstaller::DependencyInjector.new
    dependency_injector.config_file_paths = test_config_file_paths
    config_builder = dependency_injector.registry.config_builder
    config = config_builder.build_config
    config.gems[0].name.should==("testgem1")
  end
end

context "a config builder with multiple config file paths" do
  setup do
  end
  
  specify "should successfully assemble a config object" do
    test_config_file_paths = 
      File.expand_path("#{dir}/test_geminstaller_config.yml") + "," + 
      File.expand_path("#{dir}/test_geminstaller_config_2.yml")
    dependency_injector = GemInstaller::DependencyInjector.new
    dependency_injector.config_file_paths = test_config_file_paths
    config_builder = dependency_injector.registry.config_builder
    config = config_builder.build_config
    
    config.gems[0].name.should==("testgem1")
    
    config.gems[1].name.should==("testgem1")
    config.gems[1].version.should==("v2.0")
    
    config.gems[2].name.should==("testgem2")
    config.gems[2].install_options.should==(["--backtrace"])
    
    config.gems[3].name.should==("testgem3")
  end

  specify "should allow subsequent files to override defaults" do
  end
  
  specify "should allow subsequent files to override a gem"do
  end

  specify "should allow subsequent files to specify new gems"do
  end

end
