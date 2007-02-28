dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/rubygems_installer")

module GemInstaller

  class TestGemHome
    include FileUtils
    @@initialized = false
    
    def self.init_dir
      @rubygems_installer = GemInstaller::RubyGemsInstaller.new
      @rubygems_installer.install_dir = test_gem_home_dir
      @rubygems_installer.rubygems_dist_dir = GemInstaller::SpecUtils.rubygems_dist_dir
      @rubygems_installer.install
    end

    def self.test_gem_home_dir
      GemInstaller::SpecUtils.test_gem_home_dir
    end
    
    def self.config_file
      GemInstaller::SpecUtils.test_rubygems_config_file
    end
    
    def self.use
      return if @@initialized
      init_dir
      rm_config
      create_config
      GemInstaller::EmbeddedGemServer.start
      gem_cmd = 'gem'
      gem_cmd = 'gem.bat' if RUBY_PLATFORM.index('mswin')
      `#{gem_cmd} update --source #{GemInstaller::SpecUtils.embedded_gem_server_url} --config-file #{config_file}`
      @@initialized = true
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
  end
end
