dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a config builder with a single config file path" do
  setup do
    @test_config_file_paths = File.expand_path("#{dir}/test_geminstaller_config.yml")
    config_builder_spec_common_setup
  end

  specify "should successfully assemble a config object with default overrides" do
    @config.gems[0].name.should==("testgem1")
    @config.gems[0].check_for_upgrade.should==(true)
    @config.gems[0].fix_dependencies.should==(false)
    @config.gems[1].check_for_upgrade.should==(false)
    @config.gems[1].fix_dependencies.should==(true)
  end

  specify "should assign paths array to config_file_paths_array instance variable" do
    @config_builder.config_file_paths_array.should==([@test_config_file_paths])
  end

  specify "should have code coverage for default config file path" do
    GemInstaller::ConfigBuilder.default_config_file_path.should==('geminstaller.yml')
  end
end

context "a config builder with a config containing no gems" do
  setup do
    @test_config_file_paths = File.expand_path("#{dir}/empty_geminstaller_config.yml")
    config_builder_spec_common_setup
  end

  specify "should not raise an error" do
    @config.gems.size.should == 0
  end
end

context "a config builder with multiple config file paths" do
  setup do
    @test_config_file_paths = 
      File.expand_path("#{dir}/test_geminstaller_config.yml") + "," + 
      File.expand_path("#{dir}/test_geminstaller_config_2.yml")
    config_builder_spec_common_setup
  end
  
  specify "should successfully assemble a config object" do
    @config.gems[0].name.should==("testgem1")
    @config.gems[0].check_for_upgrade.should==(true)
    @config.gems[0].fix_dependencies.should==(false)
    
    @config.gems[1].name.should==("testgem1")
    @config.gems[1].version.should==("v2.0")
  end

  specify "should take defaults from previous files if they are not overridden" do
    @config.gems[0].install_options.should==(['-y'])
  end

  specify "should allow subsequent files to override defaults" do
    @config.gems[2].name.should==("testgem2")
    @config.gems[2].check_for_upgrade.should==(false)
  end
  
  specify "should allow subsequent files to override a gem"do
    @config.gems[2].name.should==("testgem2")
    @config.gems[2].install_options.should==(["--backtrace"])
  end

  specify "should allow subsequent files to specify new gems"do
    @config.gems[3].name.should==("testgem3")
    @config.gems[3].version.should==("v3.0")
    @config.gems[3].check_for_upgrade.should==(true)
  end
end

context "a config builder with multiple config file paths and no default entries in the override file" do
  setup do
    @test_config_file_paths = 
      File.expand_path("#{dir}/test_geminstaller_config.yml") + "," + 
      File.expand_path("#{dir}/test_geminstaller_config_3.yml")
    config_builder_spec_common_setup
  end
  
  specify "should successfully assemble a config object" do
  end
end

def config_builder_spec_common_setup
  dependency_injector = GemInstaller::DependencyInjector.new
  @config_builder = dependency_injector.registry.config_builder
  @config_builder.config_file_paths = @test_config_file_paths
  @config = @config_builder.build_config
end