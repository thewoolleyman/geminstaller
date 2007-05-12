# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

unless defined?(RAILS_ROOT)
  root_path = File.join(File.dirname(__FILE__), '..')

  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end

  RAILS_ROOT = root_path
end

############# Begin GemInstaller config - see http://geminstaller.rubyforge.org
require "rubygems"
require "geminstaller"

# Path(s) to your GemInstaller config file(s)
config_paths = "#{File.expand_path(RAILS_ROOT)}/config/geminstaller.yml" 

# Arguments which will be passed to GemInstaller
args = "--config #{config_paths}" 

# The 'exceptions' flag determines whether errors encountered while running GemInstaller
# should raise exceptions (and abort Rails), or just return a nonzero return code
exceptions = true 
args += " --exceptions" if exceptions

# This will use sudo by default on all non-windows platforms, but requires an entry in your
# sudoers file to avoid having to type a password.  It can be omitted if you don't want to use sudo.
# See http://geminstaller.rubyforge.org/documentation/documentation.html#dealing_with_sudo
args += " --sudo" unless RUBY_PLATFORM =~ /mswin/ 

# The 'install' method will auto-install gems as specified by the args and config
GemInstaller.run(args)

# The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
# or 'require_gem' command.  If you want to use other config file path(s), pass them as an array or comma-delimited list.
# Note that only the *first* version of any given gem will be loaded.
GemInstaller.autogem(config_paths, exceptions)
############# End GemInstaller config

unless defined?(Rails::Initializer)
  if File.directory?("#{RAILS_ROOT}/vendor/rails")
    require "#{RAILS_ROOT}/vendor/rails/railties/lib/initializer"
  else
    require 'rubygems'

    environment_without_comments = IO.readlines(File.dirname(__FILE__) + '/environment.rb').reject { |l| l =~ /^#/ }.join
    environment_without_comments =~ /[^#]RAILS_GEM_VERSION = '([\d.]+)'/
    rails_gem_version = $1

    if version = defined?(RAILS_GEM_VERSION) ? RAILS_GEM_VERSION : rails_gem_version
      rails_gem = Gem.cache.search('rails', "=#{version}").first

      if rails_gem
        require_gem "rails", "=#{version}"
        require rails_gem.full_gem_path + '/lib/initializer'
      else
        STDERR.puts %(Cannot find gem for Rails =#{version}:
    Install the missing gem with 'gem install -v=#{version} rails', or
    change environment.rb to define RAILS_GEM_VERSION with your desired version.
  )
        exit 1
      end
    else
      require_gem "rails"
      require 'initializer'
    end
  end

  Rails::Initializer.run(:set_load_path)
end