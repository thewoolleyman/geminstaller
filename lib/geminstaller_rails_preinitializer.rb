############# GemInstaller Rails Preinitializer - see http://geminstaller.rubyforge.org

# This file should be required in your Rails config/preinitializer.rb for Rails >= 2.0,
# or required in config/boot.rb before initialization for Rails < 2.0.  For example:
#   require 'geminstaller_rails_preinitializer'
#
# If you require different geminstaller command options, copy this file into your Rails app,
# modify it, and require your customized version.  For example:
#   require "#{File.expand_path(RAILS_ROOT)}/config/custom_geminstaller_rails_preinitializer.rb"

require "rubygems" 
require "geminstaller" 

module GemInstallerRailsPreinitializer
  class << self
    def preinitialize
      args = ''

      # Specify --geminstaller-output=all and --rubygems-output=all for maximum debug logging
      # args += ' --geminstaller-output=all --rubygems-output=all'

      # The 'exceptions' flag determines whether errors encountered while running GemInstaller
      # should raise exceptions (and abort Rails), or just return a nonzero return code
      args += " --exceptions" 

      # This will use sudo by default on all non-windows platforms, but requires an entry in your
      # sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
      # See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
      # Note that environment variables will NOT be passed via sudo!
      #args += " --sudo" unless RUBY_PLATFORM =~ /mswin/

      # The 'install' method will auto-install gems as specified by the args and config
      # IMPORTANT NOTE:  Under recent RubyGems versions, this will install to ~/.gem
      # The forking is a workaround to 'check_for_upgrade' in the configuration file, which causes
      # script/console crashes on Mac OS X. See http://www.ruby-forum.com/topic/101243 for details
      # It is probably best not to install from preinitializer - it has known problems
      # under Passenger, and you should be installing your gems before you initialize rails anyway,
      # via capistrano, chef, or some other mechanism.  So, it is commented for now.
      # pid = fork do
      #   GemInstaller.install(args)
      # end
      # Process.wait(pid)

      # The 'autogem' method will automatically add all gems in the GemInstaller config to your load path,
      # using the rubygems 'gem' method.  Note that only the *first* version of any given gem will be loaded.
      GemInstaller.autogem(args)
    end
  end
end

# Attempt to prevent GemInstaller from running twice, but won't work if it is executed
# in a separate interpreter (like rake tests)
GemInstallerRailsPreinitializer.preinitialize unless $geminstaller_initialized
$geminstaller_initialized = true
