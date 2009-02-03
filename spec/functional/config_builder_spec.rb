dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe GemInstaller::ConfigBuilder, "with no config file path set and no default config files existing" do
  before(:each) do
    config_builder_spec_fixture
    @config_builder = GemInstaller::ConfigBuilder.new(['not_there.yml'])
  end

  it "raises exception" do
    proc{ @config_builder.build_config }.should raise_error(GemInstaller::MissingFileError)
  end
end

describe GemInstaller::ConfigBuilder, "with no config file path set and run from dir containing geminstaller.yml" do
  before(:each) do
    Dir.chdir("#{dir}/../..") do
      File.should be_exists("./geminstaller.yml")
      config_builder_spec_fixture
      @config_builder.build_config
    end
  end

  it "should assign paths array to config_file_paths_array instance variable" do
    @config_builder.config_file_paths_array.should==(['geminstaller.yml','config/geminstaller.yml'])
  end
end

describe GemInstaller::ConfigBuilder, "with a single config file path" do
  before(:each) do
    @test_config_file_paths = File.expand_path("#{dir}/test_geminstaller_config.yml")
    config_builder_spec_common_setup
  end

  it "should successfully assemble a config object with default overrides" do
    @config.gems[0].name.should==("testgem1")
    @config.gems[0].check_for_upgrade.should==(true)
    @config.gems[0].fix_dependencies.should==(false)
    @config.gems[1].check_for_upgrade.should==(false)
    @config.gems[1].fix_dependencies.should==(false)
  end

  it "should assign paths array to config_file_paths_array instance variable" do
    @config_builder.config_file_paths_array.should==([@test_config_file_paths])
  end
end

describe GemInstaller::ConfigBuilder, "with a non-alphabetical ordering of gems in config file" do
  it "retains order of gems from original file" do
    @test_config_file_paths = File.expand_path("#{dir}/test_geminstaller_config_2.yml")
    config_builder_spec_common_setup
    @config_builder.build_config
    @config.gems[0].name.should==("testgem1")
    @config.gems[1].name.should==("testgem3")
    @config.gems[2].name.should==("testgem2")
  end
end

describe GemInstaller::ConfigBuilder, "with a config containing no gems" do
  before(:each) do
    @test_config_file_paths = File.expand_path("#{dir}/empty_geminstaller_config.yml")
    config_builder_spec_common_setup
  end

  it "should not raise an error" do
    @config.gems.size.should == 0
  end
end

describe GemInstaller::ConfigBuilder, "with a config containing a path evaluated via erb" do
  it "should evaluate working directory to path of config file" do
    @test_config_file_paths = File.expand_path("#{dir}/../fixture/evaluate_path_geminstaller_config.yml")
    @test_config_file_dir = File.dirname(@test_config_file_paths)
    config_builder_spec_common_setup
    install_options = @config.gems[0].install_options
    install_options[0].should == @test_config_file_dir
    install_options[1].should == @test_config_file_dir
  end
end

describe GemInstaller::ConfigBuilder, "with a config containing an include_config call" do
  it "should include proper config file" do
    @test_config_file_paths = File.expand_path("#{dir}/../fixture/including_geminstaller_config.yml")
    @test_config_file_dir = File.dirname(@test_config_file_paths)
    @included_config_file_dir1 = File.expand_path("#{dir}/../fixture/subdir1")
    @included_config_file_dir2 = File.expand_path("#{dir}/../fixture/subdir2")
    config_builder_spec_common_setup
    install_options1 = @config.gems[0].install_options
    install_options1[0].should == @included_config_file_dir1
    install_options1[1].should == @included_config_file_dir1
    install_options2 = @config.gems[1].install_options
    install_options2[0].should == @included_config_file_dir2
    install_options2[1].should == @included_config_file_dir2
  end
end

describe GemInstaller::ConfigBuilder, "with multiple config file paths" do
  before(:each) do
    @test_config_file_paths = 
      File.expand_path("#{dir}/test_geminstaller_config.yml") + "," + 
      File.expand_path("#{dir}/test_geminstaller_config_2.yml")
    config_builder_spec_common_setup
  end
  
  it "should successfully assemble a config object" do
    testgem1_v11 = @config.gems.detect {|g| g.name == 'testgem1' && g.version == 'v1.1'}
    testgem1_v11.check_for_upgrade.should==(true)
    testgem1_v11.fix_dependencies.should==(false)
    
    testgem1_v20 = @config.gems.detect {|g| g.name == 'testgem1' && g.version == 'v2.0'}
    testgem1_v20.should_not be_nil
  end

  it "should take defaults from previous files if they are not overridden" do
    @config.gems[0].install_options.should==(['-y'])
  end

  it "should allow subsequent files to override defaults" do
    testgem2 = @config.gems.detect {|g| g.name == 'testgem2'}
    testgem2.version.should==("v1.2")
    testgem2.check_for_upgrade.should==(false)
  end
  
  it "should allow subsequent files to override a gem"do
    testgem2 = @config.gems.detect {|g| g.name == 'testgem2'}
    testgem2.install_options.should==(["--backtrace"])
  end

  it "should allow subsequent files to specify new gems"do
    testgem3 = @config.gems.detect {|g| g.name == 'testgem3'}
    testgem3.version.should==("v3.0")
    testgem3.check_for_upgrade.should==(true)
  end
end

describe GemInstaller::ConfigBuilder, "with multiple config file paths and no default entries in the override file" do
  before(:each) do
    @test_config_file_paths = 
      File.expand_path("#{dir}/test_geminstaller_config.yml") + "," + 
      File.expand_path("#{dir}/test_geminstaller_config_3.yml")
    config_builder_spec_common_setup
  end
  
  it "should successfully assemble a config object" do
    #TODO: finish this spec
  end
end

describe GemInstaller::ConfigBuilder, "with an empty config file" do
  before(:each) do
    @test_config_file_paths = File.expand_path("#{dir}/test_empty_file.yml")
    config_builder_spec_common_setup
  end
  
  it "should return a default config" do
    @config.gems.should == []
  end
end

def config_builder_spec_fixture
  registry = GemInstaller::Registry.new
  @config_builder = registry.config_builder
  @config_builder.config_file_paths = @test_config_file_paths if @test_config_file_paths
end

def config_builder_spec_common_setup
  config_builder_spec_fixture
  @config = @config_builder.build_config
end