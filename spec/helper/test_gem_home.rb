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

    def self.init_rubygems_path
      $LOAD_PATH.unshift(rubygems_lib_dir)
    end
    
    def self.perform_rubygems_install
      @rubygems_installer = GemInstaller::RubyGemsInstaller.new
      @rubygems_installer.install_dir = rubygems_install_dir
      @rubygems_installer.test_gem_home_dir = test_gem_home_dir
      @rubygems_installer.libruby_dir = libruby_dir
      @rubygems_installer.siteruby_dir = siteruby_dir
      @rubygems_installer.siterubyver_dir = siterubyver_dir
      @rubygems_installer.rubygems_dist_dir = rubygems_dist_dir
      @rubygems_installer.install
    end
    
    def self.create_dirs
      FileUtils.mkdir(rubygems_install_dir) unless File.exist?(rubygems_install_dir)
      FileUtils.mkdir(libruby_dir) unless File.exist?(libruby_dir)
      FileUtils.mkdir(siteruby_dir) unless File.exist?(siteruby_dir)
      FileUtils.mkdir(siterubyver_dir) unless File.exist?(siterubyver_dir)
    end

    def self.config_file
      GemInstaller::TestGemHome.test_rubygems_config_file
    end

    def self.install_rubygems
      return if @@dirs_initialized
      init_rubygems_path
      rm_dir
      create_dirs
      perform_rubygems_install
      @@dirs_initialized = true
    end

    def self.start_server
      return if @@server_started
      rm_config
      create_config
      GemInstaller::EmbeddedGemServer.start
      `#{gem_cmd} update --source #{embedded_gem_server_url} --config-file #{config_file}`
      @@server_started = true
    end
    
    def self.use
      install_rubygems
      start_server
    end
    
    def self.gem_cmd
      gem_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_bin_dir} #{rubygems_bin_dir}/gem"
      gem_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_bin_dir} #{rubygems_bin_dir}/gem.bat" if RUBY_PLATFORM.index('mswin')
      gem_cmd
    end
    
    def self.rm_dir
      # FileUtils.rm_rf(test_gem_home_dir) if File.exist?(test_gem_home_dir)
      # FileUtils.rm_rf(rubygems_install_dir) if File.exist?(rubygems_install_dir)
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

    def self.stop_server
      $server_was_stopped = GemInstaller::EmbeddedGemServer.stop unless $server_was_stopped
      rm_config
      @@server_started = false
    end

    def self.uninstall_rubygems
      Gem.clear_paths
      rm_dir
      @@dirs_initialized = false
    end

    def self.reset
      stop_server
      uninstall_rubygems
    end
    
    def self.uninstall_all_test_gems
      test_gem_names.each do |test_gem_name|
        list_output = `#{gem_cmd} list #{test_gem_name}`
        next unless list_output =~ /#{test_gem_name} /
        uninstall_command = "#{gem_cmd} uninstall #{test_gem_name} --config-file #{config_file} --all --ignore-dependencies --executables"
        `#{uninstall_command}`
      end
    end
  end
end
