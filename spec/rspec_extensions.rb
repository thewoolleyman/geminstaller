module Spec
  module Runner
    class ContextRunner
      def run(exit_when_done)
        @reporter.start(number_of_specs)
        @contexts.each do |context|
          context.run(@reporter, @dry_run)
        end
        @reporter.end
        failure_count = @reporter.dump
        exit_code = (failure_count == 0) ? 0 : 1
        # Commenting these lines, because they prevent us from reaching 100% code coverage, and shouldn't be used 
        # in the context of GemInstaller tests anyway...
        # if(exit_when_done)
        #   exit(exit_code)
        # end
        exit_code
      end
    end
  end
end