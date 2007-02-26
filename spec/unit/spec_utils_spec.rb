dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")

context "spec_utils_spec: the TestGemHome class" do
  include GemInstaller::SpecUtils
  include FileUtils
  setup do
    GemInstaller::SpecUtils::EmbeddedGemServer.start
    @test_gem_home = GemInstaller::SpecUtils.test_gem_home
  end
  
  specify "should delete and recreate a test gem home" do
    # remove dir if it exists
    GemInstaller::SpecUtils::TestGemHome.reset

    # use should create dir
    GemInstaller::SpecUtils::TestGemHome.use

    # make sure rubygems dirs, including source_index, were created
    entries = Dir.entries("#{@test_gem_home}")
    ["bin","gems","source_cache"].each do |expected_subdir|
      entries.should_include(expected_subdir)
    end
  end
  
  # specify "can use test home dir as RubyGems default home dir, and reset it back to default" do
  #   # NOTE: This might fail if GEM_HOME is set to a non-standard value - I haven't tried it
  #   # reset it before the testing
  #   GemInstaller::SpecUtils::TestGemHome.reset
  #   # Gem home should equal default dir, but it should not be our test dir
  #   Gem.dir.should==("#{Gem.default_dir}")
  #   
  #   # now, use our test home dir
  #   GemInstaller::SpecUtils::TestGemHome.use
  #   # run GemRunner with generated config file pointing to test home dir (which would ordinarily reset
  #   # the Gem.dir to default if we did not override the home dir in the test config file)
  #   gem_runner_args = ['list',
  #     'pattern-which-matches-nothing-to-avoid-failure-and-minimize-stdout',
  #     '--local',
  #     '--config-file',
  #     "#{GemInstaller::SpecUtils::TestGemHome.config_file}"]
  #   Gem::GemRunner.new.run(gem_runner_args)
  #   # ...and Gem.dir should now be equal to our test dir
  #   Gem.dir.should==("#{@test_gem_home}")
  #   
  #   # ...and after another reset, it should be back to the original default
  #   GemInstaller::SpecUtils::TestGemHome.reset
  #   Gem.dir.should==("#{Gem.default_dir}")
  # end
end
