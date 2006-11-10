dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/../lib/geminstaller/requires.rb")
require 'spec'
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
$context_runner  = ::Spec::Runner::OptionParser.create_context_runner(args, false, STDERR, STDOUT)

def run_context_runner_if_necessary(has_run)
  return if has_run
  exit context_runner.run(true)
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
