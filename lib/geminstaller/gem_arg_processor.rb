module GemInstaller
  class GemArgProcessor
    #Common Options:
    #      --source URL                 Use URL as the remote source for gems
    #  -p, --[no-]http-proxy [URL]      Use HTTP proxy for remote operations
    #  -h, --help                       Get help on this command
    #  -v, --verbose                    Set the verbose level of output
    #      --config-file FILE           Use this config file instead of default
    #      --backtrace                  Show stack backtrace on errors
    #      --debug                      Turn on Ruby debugging
    GEM_COMMON_OPTIONS_WITHOUT_ARG = ['--no-http-proxy','-v','--verbose','--backtrace','--debug']
    GEM_COMMON_OPTIONS_WITH_ARG = ['--source','-p','--http_proxy','--config-file']
    
    # take an array of args, and strip all args that are not common gem command args
    def strip_non_common_gem_args(args)
      # I can't figure out a way to elegantly do this, so I hardcoded the options.  Here's how you print them
      # Gem::Command.common_options.each do |option|
      #  p option[0]
      # end

      common_args = [] 
      i = 0
      loop do
        break if i == args.size
        arg = args[i]
        if GEM_COMMON_OPTIONS_WITHOUT_ARG.include?(arg)
          common_args << arg
        else
          GEM_COMMON_OPTIONS_WITH_ARG.each do |option|
            if arg.include?(option)
              common_args << arg
              unless arg.include?('=')
                i += 1
                common_args << args[i]
              end
            end
          end
        end
        i += 1
      end
      common_args
    end
  end
end
