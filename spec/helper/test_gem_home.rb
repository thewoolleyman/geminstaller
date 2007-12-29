dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/rubygems_installer")
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
      require 'rubygems'
      init_gem_env_vars
      require geminstaller_lib_dir + "/geminstaller/rubygems_version_checker"
      install_sources if RUBYGEMS_VERSION_CHECKER.matches?('<= 0.9.4')
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
      `#{gem_cmd} update --source #{embedded_gem_server_url} --config-file #{config_file}`
      @@server_started = true
    end
    
    def self.stop_server
      $server_was_stopped = GemInstaller::EmbeddedGemServer.stop unless $server_was_stopped
      rm_config
      @@server_started = false
    end

    def self.uninstall_all_test_gems
      test_gems.each do |test_gem|
        test_gem_name = test_gem.name
        test_gem_platform = test_gem.platform
        test_gem_platform = 'x86-mswin32' if test_gem_platform == 'mswin32'
        list_output = `#{gem_cmd} list #{test_gem_name}`
        next unless list_output =~ /#{test_gem_name} /
        if RUBYGEMS_VERSION_CHECKER.matches?('>=0.9.5')
          platform_option = "--platform #{test_gem_platform}"
        end
        
        uninstall_command = "#{gem_cmd} uninstall #{test_gem_name} --all --ignore-dependencies --executables #{platform_option} --config-file #{config_file}"
        `#{uninstall_command}`
      end
    end

    protected
    
    def self.put_rubygems_on_load_path
      $LOAD_PATH.unshift(siterubyver_dir)
      $LOAD_PATH.unshift(rubygems_lib_dir)
    end

    def self.init_gem_env_vars
      ENV['GEM_HOME'] = test_gem_home_dir
      existing_gem_path = ENV['GEM_PATH']
      ENV['GEM_PATH'] = "#{existing_gem_path}:#{File.join(::Config::CONFIG['libdir'], 'ruby', 'gems', ::Config::CONFIG['ruby_version'])}"
    end

    def self.rm_dirs
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

    def self.gem_cmd
      return "#{ruby_cmd} #{rubygems_bin_dir}/gem.bat" if RUBY_PLATFORM.index('mswin')
      "#{ruby_cmd} #{rubygems_bin_dir}/gem"
    end    
  end
end
