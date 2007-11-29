dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/rubygems_installer")
require 'fileutils'

module GemInstaller

  class TestGemHome
    include FileUtils
    include GemInstaller::SpecUtils
    @@initialized = false
    
    def self.initialized?
      @@initialized
    end

    def self.init_rubygems_path
      $LOAD_PATH.unshift(rubygems_lib_dir)
    end
    
    def self.init_dirs
      self.create_dirs
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
      FileUtils.mkdir(rubygems_install_dir)
      FileUtils.mkdir(libruby_dir)
      FileUtils.mkdir(siteruby_dir)
      FileUtils.mkdir(siterubyver_dir)
    end

    def self.config_file
      GemInstaller::TestGemHome.test_rubygems_config_file
    end
    
    def self.use
      return if @@initialized
      init_rubygems_path
      rm_dir
      init_dirs
      rm_config
      create_config
      GemInstaller::EmbeddedGemServer.start
      `#{gem_cmd} update --source #{embedded_gem_server_url} --config-file #{config_file}`
      @@initialized = true
    end
    
    def self.gem_cmd
      gem_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_bin_dir} #{rubygems_bin_dir}/gem"
      gem_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_bin_dir} #{rubygems_bin_dir}/gem.bat" if RUBY_PLATFORM.index('mswin')
      gem_cmd
    end
    
    def self.rm_dir
      FileUtils.rm_rf(test_gem_home_dir) if File.exist?(test_gem_home_dir)
      FileUtils.rm_rf(rubygems_install_dir) if File.exist?(rubygems_install_dir)
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

    def self.reset
      Gem.clear_paths
      rm_config
      rm_dir
      @@initialized = false
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
