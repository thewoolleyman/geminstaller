dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

context "a GemRunnerProxy instance" do
  include GemInstaller::SpecUtils
  setup do
    GemInstaller::TestGemHome.use
    @registry = GemInstaller::create_registry
    @gem_runner_proxy = @registry.gem_runner_proxy
    @gem_interaction_handler = @registry.gem_interaction_handler
    
    GemInstaller::EmbeddedGemServer.start
  end

  specify "should return output of gem command" do
    gem_runner_args = ["list", "#{sample_multiplatform_gem_name}", "--remote"]
    gem_runner_args += install_options_for_testing

    output = @gem_runner_proxy.run(gem_runner_args)
    expected_output = /#{sample_multiplatform_gem_name} \(#{sample_multiplatform_gem_version}, #{sample_multiplatform_gem_version_low}\)/m
    output.join("\n").should_match(expected_output)
  end

  specify "should not throw an error if there is an normal rubygems exit via terminate_interaction" do
    gem_runner_args = ["--help"]
  
    output = @gem_runner_proxy.run(gem_runner_args)
    expected_output = /Usage:/m
    output.join("\n").should_match(expected_output)
  end

  specify "should return error output if there is an abnormal exit" do
    gem_runner_args = ["bogus_command"]

    begin
      @gem_runner_proxy.run(gem_runner_args)
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /Gem command was:.*gem bogus_command.*Gem command output was:.*Unknown command bogus_command/m
      error.message.should_match(expected_error_message)
    end
  end

  specify "should return descriptive message if there was an unexpected prompt due to unmet dependency" do
    use_mocks
    @mock_gem_runner.should_receive(:run).and_raise(GemInstaller::UnauthorizedDependencyPromptError.new("unexpected dependency error message"))
    dependency_prompt = 'Install required dependency somegem? [Yn]'
    @mock_output_listener.should_receive(:read!).and_return([dependency_prompt])
    begin
      @gem_runner_proxy.run(['install'])
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /unexpected dependency error message.*Gem command was:.*install.*Gem command output was:.*Install required dependency/m
      error.message.should_match(expected_error_message)
    end
  end

  specify "should return generic error output if there was an unexpected prompt due to something other than an unmet dependency" do
    use_mocks
    @mock_gem_runner.should_receive(:run).and_raise(GemInstaller::UnexpectedPromptError.new("unexpected prompt"))
    unexpected_prompt = 'some unexpected prompt?'
    @mock_output_listener.should_receive(:read!).and_return([unexpected_prompt])
    begin
      @gem_runner_proxy.run(['install'])
    rescue GemInstaller::GemInstallerError => error
      expected_error_message = /Gem command was:.*install.*Gem command output was:.*#{unexpected_prompt}/m
      error.message.should_match(expected_error_message)
    end
  end

  specify "should choose from list" do
    gem_runner_args = ["install", "#{sample_multiplatform_gem_name}", "--remote"]
    gem_runner_args += install_options_for_testing

    @gem_interaction_handler.dependent_gem = sample_multiplatform_gem
    output = @gem_runner_proxy.run(gem_runner_args)
    output.join("\n").should_match(/Successfully installed #{sample_multiplatform_gem_name}-#{sample_multiplatform_gem_version}-mswin32/m)
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
      def create_output_listener
        return @output_listener
      end
    end
    @gem_runner_proxy.gem_runner = @mock_gem_runner
    @gem_runner_proxy.output_listener = @mock_output_listener
    
    @mock_gem_runner.should_receive(:do_configuration)
  end
end
