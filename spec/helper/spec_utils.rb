module GemInstaller::SpecUtils
  SUPPRESS_RUBYGEMS_OUTPUT = false
  
  def self.test_gem_home_dir
    dir_name = "test_gem_home"
    File.expand_path(File.dirname(__FILE__) + "/../tmp/#{dir_name}")
  end
  
  def self.rubygems_dist_dir
    File.expand_path(File.dirname(__FILE__) + "/../fixture/rubygems_dist/rubygems-0.9.2")
  end
  
  def self.test_rubygems_config_file
    file_name = "test_gem.rc"
    File.expand_path(File.dirname(__FILE__) + "/../tmp/#{file_name}")
  end
  
  def self.sample_gem_name
    sample_gem_name = "stubgem"
  end

  def self.sample_gem_version
    "1.0.0"
  end

  def self.sample_dependent_gem_name
    sample_gem_name = "dependent-stubgem"
  end

  def self.sample_dependent_gem_version
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

  def sample_dependent_gem_name
    GemInstaller::SpecUtils.sample_dependent_gem_name
  end

  def sample_dependent_gem_version
    GemInstaller::SpecUtils.sample_dependent_gem_version    
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
  
  def install_options_for_testing
    GemInstaller::SpecUtils.install_options_for_testing
  end
  
  def sample_gem(install_options=install_options_for_testing)
    GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => install_options)
  end
  
  def sample_dependent_gem(install_options=install_options_for_testing)
    GemInstaller::RubyGem.new(sample_dependent_gem_name, :version => sample_dependent_gem_version, :install_options => install_options)
  end
  
  def sample_multiplatform_gem(install_options=install_options_for_testing)
    GemInstaller::RubyGem.new(sample_multiplatform_gem_name, :version => sample_multiplatform_gem_version, :platform => 'mswin32', :install_options => install_options)
  end
  
  def proc_should_raise_with_message(message_regex, &block)
    error = nil
    lambda {
      begin
        block.call
      rescue GemInstaller::GemInstallerError => error
        raise error
      end
      }.should_raise GemInstaller::GemInstallerError
      error.message.should_match(message_regex)
  end
end