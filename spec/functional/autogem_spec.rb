dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an AutoGem instance" do
  setup do
    GemInstaller::TestGemHome.use
    GemInstaller::EmbeddedGemServer.start
    @autogem = GemInstaller::AutoGem.new
    GemInstaller.run(["--silent","--config=#{dir}/live_geminstaller_config.yml"])
    # Clear out loaded specs in rubygems, otherwise the gem call won't do anything
    Gem.instance_eval { @loaded_specs.clear if @loaded_specs }
  end

  specify "should add a specified gem to the load path" do
    delete_existing_path_entries(sample_gem)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
    path_should_include_entries(sample_gem)
  end

  specify "should add same specified gem to the load path again in a separate spec (verifies that Gem.loaded specs and load path are cleaned up between specs)" do
    delete_existing_path_entries(sample_gem)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
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
