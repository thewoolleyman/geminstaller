dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../lib/geminstaller/requires.rb")
require 'spec'
require 'find' 
require 'stringio'
require File.expand_path("#{dir}/rspec_extensions.rb")
require File.expand_path("#{dir}/spec_utils.rb")

args = ARGV.dup
unless args.include?("-f") || args.include?("--format")
  args << "--format"
  args << "specdoc"
end
args << "--diff"
args << "unified"
args << $0
option_parser = ::Spec::Runner::OptionParser.new
$context_runner  = option_parser.create_context_runner(args, STDERR, STDOUT, false)

def run_context_runner_if_necessary(has_run)
  return if has_run
  retval = context_runner.run(false)
  server_was_stopped = GemInstaller::SpecUtils::EmbeddedGemServer.stop
  puts "Warning: If any tests failed with an IO permissions error, you need to ensure that the current user can install a gem" if retval != 0
  exit retval
end

at_exit do
  has_run = !context_runner.instance_eval {@reporter}.instance_eval {@start_time}.nil?
  result = $!
  if result && !result.is_a?(SystemExit) then
    p result
    raise result
  end
  return if result && !result.success?
  run_context_runner_if_necessary(has_run)
end