module GemInstaller::SpecUtils
  SUPPRESS_RUBYGEMS_OUTPUT = false
  
  def self.test_gem_home
    # TODO: This dir name is duplicated in test_rubygems_config_file.  We would have to 
    # dynamically generate that file to remove the duplication
    dir_name = "test_gem_home.tmp"
    File.dirname(__FILE__) + "/#{dir_name}"
  end
  
  def self.rubygems_dist_dir
    File.dirname(__FILE__) + "/rubygems_dist/rubygems-0.9.2"
  end
  
  def self.test_rubygems_config_file
    file_name = "test_gem.rc"
    File.dirname(__FILE__) + "/#{file_name}"
  end
  
  def self.sample_gem_name
    sample_gem_name = "stubgem"
  end

  def self.sample_gem_version
    "1.0.0"
  end

  def self.sample_multiplatform_gem_name
    "stubgem-multiplatform"
  end

  def self.sample_multiplatform_gem_version_low
    "1.0.0"
  end
  
  def self.sample_multiplatform_gem_version
    "1.0.1"
  end
  
  def self.embedded_gem_server_port
    9909
  end

  def self.embedded_gem_server_url
    "http://127.0.0.1:#{embedded_gem_server_port}"
  end
  
  def self.install_options_for_testing
    ['--backtrace','--source', embedded_gem_server_url, '--config-file', GemInstaller::SpecUtils.test_rubygems_config_file]
  end
  
  def sample_gem_name
    GemInstaller::SpecUtils.sample_gem_name
  end

  def sample_gem_version
    GemInstaller::SpecUtils.sample_gem_version    
  end

  def sample_multiplatform_gem_name
    GemInstaller::SpecUtils.sample_multiplatform_gem_name    
  end

  def sample_multiplatform_gem_version_low
    GemInstaller::SpecUtils.sample_multiplatform_gem_version_low
  end
  
  def sample_multiplatform_gem_version
    GemInstaller::SpecUtils.sample_multiplatform_gem_version    
  end
  
  def embedded_gem_server_url
    GemInstaller::SpecUtils.embedded_gem_server_url
  end
  
  def install_options_for_testing
    GemInstaller::SpecUtils.install_options_for_testing
  end
  
  def sample_gem(install_options=install_options_for_testing)
    GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => install_options)
  end
  
  def sample_multiplatform_gem(install_options=install_options_for_testing)
    GemInstaller::RubyGem.new(sample_multiplatform_gem_name, :version => sample_multiplatform_gem_version, :platform => 'mswin32', :install_options => install_options)
  end
  
  def proc_should_raise_with_message(message_regex, &block)
    error = nil
    p GemInstaller::GemInstallerError
    lambda {
      begin
        block.call
      rescue GemInstaller::GemInstallerError => error
        raise error
      end
      }.should_raise GemInstaller::GemInstallerError
      error.message.should_match(message_regex)
  end
  
  
  class EmbeddedGemServer
    @@gem_server_pid = nil
    def self.start
      return if @@gem_server_pid
      Gem.clear_paths
      gem_server_process = IO.popen("gem_server --dir=#{embedded_gem_dir} --port=#{GemInstaller::SpecUtils.embedded_gem_server_port}")
      @@gem_server_pid = gem_server_process.pid
      print "Started embedded gem server at #{embedded_gem_dir}, pid = #{@@gem_server_pid}\n"
      trap("INT") { Process.kill(9,@@gem_server_pid); exit! }
      # TODO: avoid sleep by detecting when gem_server port comes up
      sleep 3
    end
    
    def self.embedded_gem_dir
      File.dirname(__FILE__) + "/gems"
    end
    
    def self.stop
      stopped = false
      if @@gem_server_pid
        print "Killing embedded gem server at pid = #{@@gem_server_pid}\n"
        Process.kill(9,@@gem_server_pid)
        stopped = true
      end
      return stopped
    end
  end
  
  require File.expand_path("#{File.dirname(__FILE__)}/rubygems_installer")
  
  class TestGemHome
    include FileUtils
    @@initialized = false
    
    def self.init_dir
      @rubygems_installer = GemInstaller::RubyGemsInstaller.new
      @rubygems_installer.install_dir = dir
      @rubygems_installer.rubygems_dist_dir = GemInstaller::SpecUtils.rubygems_dist_dir
      @rubygems_installer.install
    end

    def self.dir
      GemInstaller::SpecUtils.test_gem_home
    end
    
    def self.config_file
      GemInstaller::SpecUtils.test_rubygems_config_file
    end
    
    def self.use
      return if @@initialized
      init_dir
      rm_config
      create_config
      GemInstaller::SpecUtils::EmbeddedGemServer.start
      `gem update --source #{GemInstaller::SpecUtils.embedded_gem_server_url} --config-file #{config_file}`
      # TODO: is the use_paths even necessary if you set the config file???
      # Gem.use_paths(dir)
      @@initialized = true
    end
    
    def self.rm_dir
      FileUtils.rm_rf(dir) if File.exist?(dir)
    end
    
    def self.rm_config
      FileUtils.rm(config_file) if File.exist?(config_file)
    end
    
    def self.create_config
      file = File.open(config_file, "w") do |f| 
        f << "gemhome: #{dir}\n"
        f << "gempath:\n"
        f << "  - #{dir}\n"
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
