module GemInstaller
  class Application
    # we have accessors instead of just writers so that we can ensure it is assembled correctly in the dependency injector test
    attr_accessor :config_builder, :gem_command_manager, :output_proxy, :arg_parser

    def run
      begin
        arg_parser.parse(ARGV)
        arg_parser_output = arg_parser.output
        if (arg_parser_output && arg_parser_output != '')
          raise RuntimeError.new(arg_parser_output)
        end
        config = @config_builder.build_config
        gems = config.gems
        gems.each do |gem|
          gem_is_installed = @gem_command_manager.is_gem_installed(gem)
          unless gem_is_installed
            @gem_command_manager.install_gem(gem)
          end
        end
      rescue Exception => e
        message = e.message
        @output_proxy.syserr(message)
        return 1
      end
      return 0
    end
  end
end