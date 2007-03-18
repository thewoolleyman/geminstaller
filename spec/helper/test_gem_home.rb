dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/rubygems_installer")
require 'fileutils'

module GemInstaller

  class TestGemHome
    include FileUtils
    include GemInstaller::SpecUtils
    @@initialized = false
    
    def self.init_dir
      @rubygems_installer = GemInstaller::RubyGemsInstaller.new
      @rubygems_installer.install_dir = test_gem_home_dir
      @rubygems_installer.rubygems_dist_dir = rubygems_dist_dir
      @rubygems_installer.install
    end

    def self.config_file
      GemInstaller::TestGemHome.test_rubygems_config_file
    end
    
    def self.use
      return if @@initialized
      init_dir
      rm_config
      create_config
      GemInstaller::EmbeddedGemServer.start
      `#{gem_cmd} update --source #{embedded_gem_server_url} --config-file #{config_file}`
      @@initialized = true
    end
    
    def self.gem_cmd
      gem_cmd = 'gem'
      gem_cmd = 'gem.bat' if RUBY_PLATFORM.index('mswin')
      gem_cmd
    end
    
    def self.rm_dir
      FileUtils.rm_rf(test_gem_home_dir) if File.exist?(test_gem_home_dir)
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
