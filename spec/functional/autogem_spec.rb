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
    expected_load_path_entry_lib = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/lib"
    expected_load_path_entry_bin = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/bin"
    $:.delete(expected_load_path_entry_lib)
    $:.delete(expected_load_path_entry_bin)
    $:.should_not_include(expected_load_path_entry_lib)
    $:.should_not_include(expected_load_path_entry_bin)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
    dir = File.dirname(__FILE__)
    $:.should_include(expected_load_path_entry_lib)
    $:.should_include(expected_load_path_entry_bin)
  end

  specify "should add a specified gem to the load path #2" do
    expected_load_path_entry_lib = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/lib"
    expected_load_path_entry_bin = "#{test_gem_home_dir}/gems/#{sample_gem_name}-#{sample_gem_version}/bin"
    $:.delete(expected_load_path_entry_lib)
    $:.delete(expected_load_path_entry_bin)
    $:.should_not_include(expected_load_path_entry_lib)
    $:.should_not_include(expected_load_path_entry_bin)
    added_gems = @autogem.autogem([sample_gem])
    added_gems[0].should ==(sample_gem)
    dir = File.dirname(__FILE__)
    $:.should_include(expected_load_path_entry_lib)
    $:.should_include(expected_load_path_entry_bin)
  end

  teardown do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end
  
  def load_path_contains_substring?(expected_entry_substring)
    $:.each do |load_path_entry|
      return true if load_path_entry =~ /#{Regexp.escape(expected_entry_substring)}/
    end
    return false
  end
end
