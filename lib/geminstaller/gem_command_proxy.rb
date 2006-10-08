require 'rubygems'
require 'rubygems/doc_manager'
require 'rubygems/config_file'
require 'rubygems/cmd_manager'
require 'rubygems/gem_runner'
require 'rubygems/remote_installer'
require 'rubygems/installer'

module GemInstaller
  class GemCommandProxy
    def is_gem_installed(gem_name)
      gems = Gem::cache.refresh!
      gems = Gem::cache.search(/.*#{gem_name}$/)
      gems.each do |gem|
        return true if gem.name == gem_name
      end
      return false
    end

    def uninstall_gem(gem_name)
      run_gem_command('uninstall',gem_name)
    end

    def install_gem(gem_name)
      run_gem_command('install',gem_name)
    end

    def run_gem_command(gem_command,gem_name)
      Gem::GemRunner.new.run([gem_command,"#{gem_name}"])
    end
  end
end





