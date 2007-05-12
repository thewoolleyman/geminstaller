dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../helper/spec_helper")

describe "a GemArgProcessor instance" do
  before(:each) do
    @gem_arg_processor = GemInstaller::GemArgProcessor.new
  end

  it "can strip all non-common args from an args array for options without a parameter" do
    args = GemInstaller::GemArgProcessor::GEM_COMMON_OPTIONS_WITHOUT_ARG.dup
    processed_args = @gem_arg_processor.strip_non_common_gem_args(args)
    processed_args.should==(args)
    
    args_with_invalid = args.dup
    args_with_invalid << "-pinvalid"
    args_with_invalid << "--debuginvalid"
    processed_args = @gem_arg_processor.strip_non_common_gem_args(args)
    processed_args.should==(args)
  end

  it "can strip all non-common args from an args array for options with a parameter" do
    # args = ['--source','http://foo.bar','--http_proxy','myproxy','--config-file','myconfig']
    # processed_args = @gem_arg_processor.strip_non_common_gem_args(args)
    # processed_args.should==(args)

    args = ['--source=http://foo.bar','--http_proxy=myproxy','--config-file=myconfig']
    processed_args = @gem_arg_processor.strip_non_common_gem_args(args)
    processed_args.should==(args)
  end
end

