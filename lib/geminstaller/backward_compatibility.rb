# this file supports backward compatibility for prior versions of RubyGems
RUBYGEMS_VERSION_CHECKER = GemInstaller::RubyGemsVersionChecker.new

# 0.9.4 reorganized commands to Gem::Commands:: module from Gem::
if RUBYGEMS_VERSION_CHECKER.less_than?('0.9.4')
  module Gem
    class Gem::Commands::ListCommand
      extend Gem::ListCommand
    end
    class Gem::Commands::ListCommand
      extend Gem::QueryCommand
    end
  end
end