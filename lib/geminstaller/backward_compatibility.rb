# this file supports backward compatibility for prior versions of RubyGems
RUBYGEMS_VERSION_CHECKER = GemInstaller::RubyGemsVersionChecker.new

# 0.9.4 reorganized commands to Gem::Commands:: module from Gem::
if RUBYGEMS_VERSION_CHECKER.less_than?('0.9.4')
  LIST_COMMAND_CLASS = Gem::ListCommand
  QUERY_COMMAND_CLASS = Gem::QueryCommand
else
  LIST_COMMAND_CLASS = Gem::Commands::ListCommand
  QUERY_COMMAND_CLASS = Gem::Commands::QueryCommand
end
