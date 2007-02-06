module GemInstaller::SpecUtils
  SUPPRESS_RUBYGEMS_OUTPUT = false
  
  def sample_gem_name
    sample_gem_name = "stubgem"
  end

  def sample_gem_version
    sample_gem_version = "1.0.0"
  end

  def sample_multiplatform_gem_name
    sample_gem_name = "stubgem-multiplatform"
  end

  def sample_multiplatform_gem_version
    sample_gem_version = "1.0.1"
  end
  
  def local_gem_server_port
    9909
  end

  def local_gem_server_url
    "http://127.0.0.1:#{local_gem_server_port}"
  end
  
  def install_options_for_testing
    ["--source", local_gem_server_url]
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
      gem_server_process = IO.popen("gem_server --dir=#{embedded_gem_dir} --port=9909")
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
        begin
          Process.kill(9,@@gem_server_pid)
        rescue
          puts "Warning: The embedded gem_server process may not have been stopped.  You may need to kill it manually..."          
        end
        stopped = true
      end
      return stopped
    end
  end
  
  class TestGemHome
    include FileUtils
    @@dir_name = "test_gem_home.tmp"
    @@dir = File.dirname(__FILE__) + "/#{@@dir_name}"
    
    def self.init
      FileUtils.rm_rf(@@dir)
      FileUtils.mkdir(@@dir)
    end

    def self.dir
      @@dir
    end
    
    def self.use
      init
      Gem.use_paths(@@dir)
    end

    def self.reset
      Gem.clear_paths
    end
  end
end