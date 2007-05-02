# Don't change this file. Configuration is done in config/environment.rb and config/environments/*.rb

unless defined?(RAILS_ROOT)
  root_path = File.join(File.dirname(__FILE__), '..')

  unless RUBY_PLATFORM =~ /mswin32/
    require 'pathname'
    root_path = Pathname.new(root_path).cleanpath(true).to_s
  end

  RAILS_ROOT = root_path
end

# Begin GemInstaller config - see http://geminstaller.rubyforge.org
require "rubygems"
require "geminstaller"
use_sudo = true # set this flag to false if you don't need root access to install gems
config_paths = ["#{File.expand_path(RAILS_ROOT)}/config/geminstaller.yml"]
if RUBY_PLATFORM =~ /mswin/ or !use_sudo
  # GemInstaller can be invoked from Ruby if you DON'T require root access to install gems
  begin
    args = ['--config'] << config_paths
    GemInstaller.run(args)
  rescue Exception => e
    # Abort Rails startup if GemInstaller failed (optional)
    raise e
  end
else
  # GemInstaller must be invoked via the executable if you DO require root access to install gems
  command = "geminstaller --sudo --config=#{config_paths.join(',')}"
  result = system(command)
  # Abort Rails startup if GemInstaller failed (optional)
  raise "GemInstaller failed, return code = #{$?}, command = #{command}" unless result and $? == 0
end

# The 'autogem' method will automatically add all gems in the GemInstaller config to your load path, using the 'gem'
# or 'require_gem' command.  If you want to use other config file path(s), pass them as an array or comma-delimited list.
# Note that only the *first* version of any given gem will be loaded.
GemInstaller.autogem("#{RAILS_ROOT}/config/geminstaller.yml")

# The following line will allow you to debug against a local checkout of geminstaller - make sure the geminstaller gem is not installed
#system "ruby /my/path/to/geminstaller/bin/geminstaller --sudo --config=#{RAILS_ROOT}/config/geminstaller.yml"
# End GemInstaller config

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