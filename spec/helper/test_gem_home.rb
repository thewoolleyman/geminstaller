dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/rubygems_installer")
require File.expand_path("#{dir}/spec_utils")
require 'fileutils'

module GemInstaller

  class TestGemHome
    include FileUtils
    include GemInstaller::SpecUtils
    @@dirs_initialized = false
    @@server_started = false

    def self.initialized?
      @@dirs_initialized and @@server_started
    end

    def self.use
      install_rubygems
      start_server
      Gem.class_eval { @platforms = nil } if GemInstaller::RubyGemsVersionChecker.matches?(['>=0.9.5', '<=1.1.0'])
      Gem.platforms.clear if GemInstaller::RubyGemsVersionChecker.matches?('>=1.1.0')
    end
    
    def self.reset
      stop_server
      uninstall_rubygems
    end
    
    def self.install_rubygems
      return if @@dirs_initialized
      rm_dirs
      create_dirs
      put_rubygems_on_load_path
      init_gem_env_vars
      require geminstaller_lib_dir + "/geminstaller/rubygems_version_checker"
      install_sources if GemInstaller::RubyGemsVersionChecker.matches?('<= 0.9.4')
      @@dirs_initialized = true
    end

    def self.uninstall_rubygems
      Gem.clear_paths
      rm_dirs
      @@dirs_initialized = false
    end

    def self.start_server
      return if @@server_started
      rm_config
      create_config
      GemInstaller::EmbeddedGemServer.start
      cmd = "#{gem_cmd} update --source #{embedded_gem_server_url} --config-file #{config_file}"
      puts "Updating from embedded gem server, cmd = #{cmd}"
      output = `#{cmd}`
      raise "Failure updating from embedded gem server, cmd = #{cmd}" unless $?.success?
      @@server_started = true
    end
    
    def self.stop_server
      $server_was_stopped = GemInstaller::EmbeddedGemServer.stop unless $server_was_stopped
      rm_config
      @@server_started = false
    end

    def self.uninstall_all_test_gems
      if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
        rm_test_gem_home_dir
        require 'rubygems/source_info_cache'
        Gem::SourceInfoCache.reset if GemInstaller::RubyGemsVersionChecker.matches?('>1.0.1')
      else
        uninstall_all_test_gems_via_rubygems
      end
    end
    
    def self.uninstall_all_test_gems_via_rubygems
      test_gems.each do |test_gem|
        test_gem_name = test_gem.name
        test_gem_platform = test_gem.platform
        test_gem_platform = 'x86-mswin32' if test_gem_platform == 'mswin32'
        list_output = `#{gem_cmd} list #{test_gem_name}`
        next unless list_output =~ /#{test_gem_name} /
        if GemInstaller::RubyGemsVersionChecker.matches?('>=0.9.5')
          platform_option = "--platform #{test_gem_platform}"
        end
        
        uninstall_command = "#{gem_cmd} uninstall #{test_gem_name} --all --ignore-dependencies --executables #{platform_option} --config-file #{config_file}"
        `#{uninstall_command}`
      end
    end

    def self.put_rubygems_on_load_path
      remove_rubygems_from_require_array
      remove_rubygems_constants
      $LOAD_PATH.unshift(siterubyver_dir)
      $LOAD_PATH.unshift(rubygems_lib_dir)
      require 'rubygems'
      hack_in_correct_rubygems_version_because_rubygems_refuses_to_allow_it_to_be_changed_in_trunk
      print "\nReset RubyGems version, ENV['RUBYGEMS_VERSION'] == '#{ENV['RUBYGEMS_VERSION']}', Gem::RubyGemsVersion == '#{Gem::RubyGemsVersion}'\n"
    end
    
    protected

    def self.remove_rubygems_from_require_array
      require_array_copy = $".dup
      require_array_copy.each do |require_array_entry|
        $".delete(require_array_entry) if require_array_entry =~ /rubygems/
      end
      # point "require" back at the standard Ruby "require" method
      # if RubyGems has already aliased gem_original_require to the original require...
      if Kernel.private_method_defined?(:gem_original_require)
        # get an unbound method reference to the original require method
        unbound_gem_original_require = Kernel.send(:instance_method, :gem_original_require)
        # then remove the overridden RubyGems require
        Kernel.send(:remove_method, :require)
        # and define require to invoke the original require method 
        Kernel.send(:define_method, :require) {|path| unbound_gem_original_require.bind(Kernel).call(path) }
      end
    end

    def self.remove_rubygems_constants
      return unless defined? Gem
      # TODO: ignore undefined class name constants so it works under older rubygems versions (e.g. Gem::Command)
      constants_to_remove = [
        {:class => Gem, :name => :RubyGemsVersion},
        {:class => Gem, :name => :VERSION},
        {:class => Gem, :name => :MUTEX},
        {:class => Gem, :name => :RubyGemsPackageVersion},
        {:class => Gem, :name => :WIN_PATTERNS},
        {:class => Gem, :name => :MARSHAL_SPEC_DIR},
        {:class => Gem, :name => :YAML_SPEC_DIR},
        {:class => Gem::Version, :name => :VERSION_PATTERN},
        {:class => Gem::Requirement, :name => :OPS},
        {:class => Gem::Requirement, :name => :OP_RE},
        {:class => Gem, :name => :Requirement},
        {:class => Gem::Version, :name => :Requirement},
        {:class => Gem::Dependency, :name => :TYPES},
        {:class => Gem::Platform, :name => :RUBY},
        {:class => Gem::Platform, :name => :CURRENT},
        {:class => Gem::Specification, :name => :NONEXISTENT_SPECIFICATION_VERSION},
        {:class => Gem::Specification, :name => :CURRENT_SPECIFICATION_VERSION},
        {:class => Gem::Specification, :name => :SPECIFICATION_VERSION_HISTORY},
        {:class => Gem::Specification, :name => :MARSHAL_FIELDS},
        {:class => Gem::Specification, :name => :TODAY},
        {:class => Gem, :name => :Cache},
        {:class => Gem::ConfigFile, :name => :DEFAULT_BACKTRACE},
        {:class => Gem::ConfigFile, :name => :DEFAULT_BENCHMARK},
        {:class => Gem::ConfigFile, :name => :DEFAULT_BULK_THRESHOLD},
        {:class => Gem::ConfigFile, :name => :DEFAULT_VERBOSITY},
        {:class => Gem::ConfigFile, :name => :DEFAULT_UPDATE_SOURCES},
        {:class => Gem::ConfigFile, :name => :OPERATING_SYSTEM_DEFAULTS},
        {:class => Gem::ConfigFile, :name => :PLATFORM_DEFAULTS},
        {:class => Gem::ConfigFile, :name => :SYSTEM_WIDE_CONFIG_FILE},
        {:class => Gem::Command, :name => :HELP}
      ]
      constants_to_remove.each do |constant|
        begin
          constant[:class].send(:remove_const,constant[:name])
        rescue NameError => e
          puts "Error removing constant from installed RubyGems: #{e.message}"
        end
      end
    end

    def self.hack_in_correct_rubygems_version_because_rubygems_refuses_to_allow_it_to_be_changed_in_trunk
      # http://rubyforge.org/pipermail/rubygems-developers/2009-June/004749.html
      # http://rubyforge.org/pipermail/rubygems-developers/2009-June/004750.html
      return unless rubygems_dist == 'trunk'
      correct_version = Gem::RubyGemsVersion + '.1'
      Gem.send(:remove_const,:RubyGemsVersion)
      Gem.send(:remove_const,:VERSION)
      Gem.const_set(:RubyGemsVersion, correct_version)
      Gem.const_set(:VERSION, correct_version)
    end

    def self.init_gem_env_vars
      ENV['GEM_HOME'] = test_gem_home_dir
      # Copied from rubygems.rb path method
      paths = [ENV['GEM_PATH']]
      
      # Copied from defaults.rb default_dir method,
      # we need to ensure that /Library/Ruby/Gems is on the GEM_PATH in Leopard
      require geminstaller_lib_dir + "/geminstaller/rubygems_version_checker"
      if GemInstaller::RubyGemsVersionChecker.matches?('<=0.9.5') 
        if defined? RUBY_FRAMEWORK_VERSION
          paths << File.join(File.dirname(Config::CONFIG["sitedir"]), "Gems", Config::CONFIG['ruby_version'])
        else
          paths << File.join(Config::CONFIG['libdir'], 'ruby', 'gems', Config::CONFIG['ruby_version'])
        end
      else
        if defined? RUBY_FRAMEWORK_VERSION
          paths << File.join(File.dirname(Gem::ConfigMap[:sitedir]), 'Gems', Gem::ConfigMap[:ruby_version])
        else
          paths << File.join(Gem::ConfigMap[:libdir], 'ruby', 'gems', Gem::ConfigMap[:ruby_version])
        end
      end

      paths << APPLE_GEM_HOME if defined? APPLE_GEM_HOME
      
      ENV['GEM_PATH'] = paths.compact.join(File::PATH_SEPARATOR)
    end

    def self.rm_dirs
      rm_test_gem_home_dir
    end
    
    def self.rm_test_gem_home_dir
      FileUtils.rm_rf(test_gem_home_dir) if File.exist?(test_gem_home_dir)
    end
    
    def self.create_dirs
      FileUtils.mkdir(test_gem_home_dir) unless File.exist?(test_gem_home_dir)
      FileUtils.mkdir(siteruby_dir) unless File.exist?(siteruby_dir)
      FileUtils.mkdir(siterubyver_dir) unless File.exist?(siterubyver_dir)
    end

    def self.install_sources
      @rubygems_installer = GemInstaller::RubyGemsInstaller.new
      @rubygems_installer.gem_home_dir = test_gem_home_dir
      @rubygems_installer.rubygems_dist_dir = rubygems_dist_dir
      @rubygems_installer.install_sources
    end
    
    def self.config_file
      GemInstaller::TestGemHome.test_rubygems_config_file
    end

    def self.rm_config
      FileUtils.rm(config_file) if File.exist?(config_file)
    end
    
    def self.create_config
      file = File.open(config_file, "w") do |f| 
        f << "gemhome: #{test_gem_home_dir}\n"
        f << "gempath:\n"
        f << "  - #{test_gem_home_dir}\n"
      end 
    end
  end
end
