module Gem
  class GemRunner
    public :do_configuration
  end
  if RUBYGEMS_VERSION_CHECKER.less_than?('0.9.4')
    class CmdManager
      attr_reader :commands
    end
  else
    class CommandManager
      attr_reader :commands
    end
  end
end

