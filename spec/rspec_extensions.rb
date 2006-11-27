module Spec
  module Mocks
    class BaseExpectation

      def invoke(args, block)
        @order_group.handle_order_constraint self

        begin
          if @exception_to_raise.class == Class
            @exception_instance_to_raise = @exception_to_raise.new
          else 
            @exception_instance_to_raise = @exception_to_raise
          end
          Kernel::raise @exception_to_raise unless @exception_to_raise.nil?
          Kernel::throw @symbol_to_throw unless @symbol_to_throw.nil?

          if !@method_block.nil?
            return invoke_method_block(args)
          elsif !@args_to_yield.nil?
            return invoke_with_yield(block)
          elsif @consecutive
            return invoke_consecutive_return_block(args, block)
          else
            return invoke_return_block(args, block)
          end
        ensure
          @received_count += 1
        end
      end
    end
  end

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
        if(exit_when_done)
          exit(exit_code)
        end
        exit_code
      end
    end
  end
end