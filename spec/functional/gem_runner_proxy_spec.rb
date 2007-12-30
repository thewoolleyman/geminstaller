dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a GemRunnerProxy instance" do
  before(:each) do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_runner_proxy = @registry.gem_runner_proxy
    @gem_interaction_handler = @registry.gem_interaction_handler
  end

  it "should return output of gem command" do
    gem_runner_args = ["list", "#{sample_multiplatform_gem_name}", "--remote"]
    gem_runner_args += install_options_for_testing

    output = @gem_runner_proxy.run(gem_runner_args)
    
    if RUBYGEMS_VERSION_CHECKER.matches?('=0.9.5')
      # bug in 0.9.5 that double-lists versions
      expected_versions = "#{sample_multiplatform_gem_version}, #{sample_multiplatform_gem_version}, #{sample_multiplatform_gem_version_low}"
    else
      expected_versions = "#{sample_multiplatform_gem_version}, #{sample_multiplatform_gem_version_low}"
    end
    
    expected_output = /#{sample_multiplatform_gem_name} \(#{expected_versions}\)/m
    output.join("\n").should match(expected_output)
  end

  it "should not throw an error if there is an normal rubygems exit via terminate_interaction" do
    gem_runner_args = ["--help"]
  
    output = @gem_runner_proxy.run(gem_runner_args)
    expected_output = /Usage:/m
    output.join("\n").should match(expected_output)
  end

  it "should return error output if there is an abnormal exit" do
    gem_runner_args = ["bogus_command"]

    begin
      @gem_runner_proxy.run(gem_runner_args)
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /Gem command was:.*gem bogus_command.*Gem command output was:.*Unknown command bogus_command/m
      error.message.should match(expected_error_message)
    end
  end

  it "should return descriptive message if there was an unexpected prompt due to unmet dependency" do
    use_mocks
    @mock_gem_runner.should_receive(:run).and_raise(GemInstaller::UnauthorizedDependencyPromptError.new("unexpected dependency error message"))
    dependency_prompt = 'Install required dependency somegem? [Yn]'
    @mock_output_listener.should_receive(:read!).and_return([dependency_prompt])
    begin
      @gem_runner_proxy.run(['install'])
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /unexpected dependency error message.*Gem command was:.*install.*Gem command output was:.*Install required dependency/m
      error.message.should match(expected_error_message)
    end
  end

  it "should return generic error output if there was an unexpected prompt due to something other than an unmet dependency" do
    use_mocks
    @mock_gem_runner.should_receive(:run).and_raise(GemInstaller::UnexpectedPromptError.new("unexpected prompt"))
    unexpected_prompt = 'some unexpected prompt?'
    @mock_output_listener.should_receive(:read!).and_return([unexpected_prompt])
    begin
      @gem_runner_proxy.run(['install'])
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /Gem command was:.*install.*Gem command output was:.*#{unexpected_prompt}/m
      error.message.should match(expected_error_message)
    end
  end

  it "returns custom error output if there was an access error" do
    use_mocks
    error_message = "error message"
    @mock_gem_runner.should_receive(:run).and_raise(GemInstaller::GemInstallerError.new(error_message))
    access_error = 'Errno::EACCES'
    @mock_output_listener.should_receive(:read!).and_return([access_error])
    begin
      @gem_runner_proxy.run(['install'])
    rescue GemInstaller::GemInstallerAccessError => error
      expected_error_message = /don't have permission.*Gem command was:.*install.*Gem command output was:.*#{access_error}/m
      error.message.should match(expected_error_message)
    end
  end

  it "should choose from list" do
    gem_runner_args = ["install", "#{sample_multiplatform_gem_name}", "--remote"]
    gem_runner_args += install_options_for_testing

    @gem_interaction_handler.dependent_gem = sample_multiplatform_gem
    output = @gem_runner_proxy.run(gem_runner_args)
    output.join("\n").should match(/Successfully installed #{sample_multiplatform_gem_name}-#{sample_multiplatform_gem_version}/m)
  end
  
  after(:each) do
    GemInstaller::TestGemHome.uninstall_all_test_gems
  end

  def use_mocks
    @mock_gem_runner = mock("Mock Gem Runner")
    @mock_output_listener = mock("Mock Output Listener")
    @gem_runner_proxy.instance_eval do
      def gem_runner=(runner)
        @gem_runner = runner
      end
      
      def output_listener=(listener)
       @output_listener = listener
     end
     
      def create_gem_runner
        return @gem_runner
      end
    end
    @gem_runner_proxy.gem_runner = @mock_gem_runner
    @gem_runner_proxy.output_listener = @mock_output_listener
    
    @mock_gem_runner.should_receive(:do_configuration)
  end
end
