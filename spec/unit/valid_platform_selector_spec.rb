dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "an ValidPlatformSelector with prefer_binary_platform == true and no dependent_gem_platform passed" do
  setup do
    common_setup_valid_platform_selector(true)
  end

  specify "should select RUBY_PLATFORM platform first, and default platform (ruby) last" do
    should_select_correct_valid_platforms("i686-darwin8.7.1", nil, ['686-darwin', 'ruby'])
    should_select_correct_valid_platforms("powerpc-darwin", nil, ['powerpc', 'ruby'])
    should_select_correct_valid_platforms("i386-mswin32", nil, ['mswin32', 'ruby'])
    should_select_correct_valid_platforms("i686-linux", nil, ['686-linux', 'ruby'])
  end
end

context "an ValidPlatformSelector with prefer_binary_platform == true and a dependent_gem_platform passed" do
  specify "should select dependent_gem_platform first, RUBY_PLATFORM platform second, and default platform (ruby) last" do
    common_setup_valid_platform_selector(true)
    should_select_correct_valid_platforms("i686-darwin8.7.1", "dependent-gem-platform", ['dependent-gem-platform', '686-darwin', 'ruby'])
  end

  specify "should not duplicate dependent gem platform if it is already in the list (or if it is ruby, which will always be in the list)" do
    common_setup_valid_platform_selector(true)
    should_select_correct_valid_platforms("solaris", "solaris", ['solaris', 'ruby'])
    should_select_correct_valid_platforms("solaris", "ruby", ['solaris', 'ruby'])
  end

  specify "should output a message indicating what platforms it selected" do
    @valid_platform_selector = GemInstaller::ValidPlatformSelector.new
    options = {:prefer_binary_platform => true}
    @valid_platform_selector.options = options
    @mock_output_filter = mock('Mock Output Filter')
    @valid_platform_selector.output_filter = @mock_output_filter
    expected_message = /Selecting .* RUBY_PLATFORM='.*', dependent_gem_platform=.*ruby.*, valid_platforms=.*solaris.*ruby/m
    @mock_output_filter.should_receive(:geminstaller_output).once.with(:debug, expected_message)    
    should_select_correct_valid_platforms("solaris", "ruby", ['solaris', 'ruby'])
  end
end

context "an ValidPlatformSelector with prefer_binary_platform == false and no dependent_gem_platform passed" do
  setup do
    common_setup_valid_platform_selector(false)
  end

  specify "should select default platform (ruby) first, and RUBY_PLATFORM platform last" do
    should_select_correct_valid_platforms("i686-darwin8.7.1", nil, ['ruby', '686-darwin'])
  end
end

context "an ValidPlatformSelector with prefer_binary_platform == false and a dependent_gem_platform passed" do
  setup do
    common_setup_valid_platform_selector(false)
  end

  specify "should select dependent_gem_platform first, default platform (ruby) next, and RUBY_PLATFORM platform last" do
    should_select_correct_valid_platforms("i686-darwin8.7.1", "dependent-gem-platform", ['dependent-gem-platform', 'ruby', '686-darwin'])
  end
end

def common_setup_valid_platform_selector(prefer_binary_platform)
  @valid_platform_selector = GemInstaller::ValidPlatformSelector.new
  options = {:prefer_binary_platform => prefer_binary_platform}
  @valid_platform_selector.options = options
  @mock_output_filter = mock('Mock Output Filter')
  @valid_platform_selector.output_filter = @mock_output_filter
  @mock_output_filter.should_receive(:geminstaller_output).any_number_of_times.with(:anything,:anything)    
end

def should_select_correct_valid_platforms(ruby_platform, dependent_gem_platform, expected_valid_platforms)
  @valid_platform_selector.ruby_platform = ruby_platform
  valid_platforms = @valid_platform_selector.select(dependent_gem_platform)
  valid_platforms.should == expected_valid_platforms
end


