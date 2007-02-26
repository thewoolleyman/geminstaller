dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../../lib/geminstaller/requires.rb")
require 'spec'
require 'find' 
require 'stringio'
require File.expand_path("#{dir}/spec_utils.rb")
require File.expand_path("#{dir}/test_gem_home.rb")
require File.expand_path("#{dir}/embedded_gem_server.rb")

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
  retval = 1
  begin
    retval = context_runner.run(false)
  ensure
    server_was_stopped = GemInstaller::EmbeddedGemServer.stop
    GemInstaller::TestGemHome.reset
  end
  retval ||= 0
  puts "Warning: If any tests failed with an IO permissions error, you need to ensure that the current user can install a gem, or run everything with sudo" if retval != 0
  exit retval
end

def raise_if_result_not_system_exit(result)
  if result && !result.is_a?(SystemExit) then
    p result
    raise result
  end
end

at_exit do
  has_run = !context_runner.instance_eval {@reporter}.instance_eval {@start_time}.nil?
  result = $!
  raise_if_result_not_system_exit(result)
  return if result && !result.success?
  run_context_runner_if_necessary(has_run)
end