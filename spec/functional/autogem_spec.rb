dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an AutoGem instance" do
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    @registry = GemInstaller::create_registry
    @autogem = @registry.autogem
    # install all the sample gems
    GemInstaller.run(["--silent","--config=#{dir}/live_geminstaller_config_all_sample_gems.yml"])
    # Clear out loaded specs in rubygems, otherwise the gem call won't do anything
    Gem.instance_eval { @loaded_specs.clear if @loaded_specs }
  end

  specify "should add a specified gem to the load path" do
    delete_existing_path_entries(sample_gem)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
    path_should_include_entries(sample_gem)
  end
  
  specify "should not add a specified gem to the load path if the no_autogem property is set" do
    @sample_gem_with_no_autogem = sample_gem
    @sample_gem_with_no_autogem.no_autogem = true
    delete_existing_path_entries(@sample_gem_with_no_autogem)
    added_gems = @autogem.autogem([@sample_gem_with_no_autogem])
    added_gems.size.should == 0
    load_path_entries(@sample_gem_with_no_autogem).each do |entry|
      $:.should_not_include(entry)
    end
  end
  
  specify "should add same specified gem to the load path again in a separate spec (verifies that Gem.loaded specs and load path are cleaned up between specs)" do
    delete_existing_path_entries(sample_gem)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
    path_should_include_entries(sample_gem)
  end

  specify "should add a dependent gem and it's dependency to the load path" do
    delete_existing_path_entries(sample_dependent_gem)
    delete_existing_path_entries(sample_gem)
    
    added_gems = @autogem.autogem([sample_dependent_gem])
    added_gem_names = []
    added_gems.each do |added_gem|
      added_gem_names << added_gem.name
    end
    added_gem_names.should_include(sample_dependent_gem.name)
    added_gem_names.should_include(sample_gem.name)
    
    path_should_include_entries(sample_dependent_gem)
    path_should_include_entries(sample_gem)
  end

  specify "should add all gems in a multilevel dependency chain to the load path" do
    delete_existing_path_entries(sample_dependent_multilevel_gem)
    delete_existing_path_entries(sample_dependent_gem)
    delete_existing_path_entries(sample_gem)
    
    added_gems = @autogem.autogem([sample_dependent_multilevel_gem])
    added_gem_names = []
    added_gems.each do |added_gem|
      added_gem_names << added_gem.name
    end
    added_gem_names.should_include(sample_dependent_multilevel_gem.name)
    added_gem_names.should_include(sample_dependent_gem.name)
    added_gem_names.should_include(sample_gem.name)
    
    path_should_include_entries(sample_dependent_multilevel_gem)
    path_should_include_entries(sample_dependent_gem)
    path_should_include_entries(sample_gem)
  end

  def path_should_include_entries(gem)
    load_path_entries(gem).each do |entry|
      $:.should_include(entry)
    end
  end

  def delete_existing_path_entries(gem)
    load_path_entries(gem).each do |entry|
      $:.delete(entry)
      $:.should_not_include(entry)
    end
  end

  def load_path_entries(gem)
    name = gem.name
    version = gem.version
    [load_path_entry(name,version,"lib"),load_path_entry(name,version,"bin")]
  end

  def load_path_entry(name,version,subdir)
    "#{test_gem_home_dir}/gems/#{name}-#{version}/#{subdir}"
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
end
