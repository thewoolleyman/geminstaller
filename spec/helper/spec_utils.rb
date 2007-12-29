module GemInstaller
  module SpecUtils  
  def self.included(base)
    base.extend(ClassMethods)
  end

  module ClassMethods
    def test_gems
      [sample_gem, sample_dependent_gem, sample_dependent_depends_on_multiplatform_gem,
        sample_multiplatform_gem_ruby, sample_multiplatform_gem,
        sample_dependent_multilevel_gem, sample_dependent_multiplatform_gem]
    end
    
    def ruby_cmd
      "ruby -I #{rubygems_lib_dir}:#{rubygems_bin_dir}"
    end
      
    def rubygems_version
      ENV['RUBYGEMS_VERSION'] || "1.0.1"
    end
  
    def geminstaller_lib_dir
      File.expand_path(File.dirname(__FILE__) + "/../../lib")
    end

    def test_gem_home_dir
      dir_name = "test_gem_home"
      File.expand_path(File.dirname(__FILE__) + "/../tmp/#{dir_name}")
    end

    def siteruby_dir
      "#{test_gem_home_dir}/site_ruby"
    end
  
    def siterubyver_dir
      "#{siteruby_dir}/1.8"
    end
  
    def rubygems_dist_dir
      File.expand_path(File.dirname(__FILE__) + "/../fixture/rubygems_dist/rubygems-#{rubygems_version}")
    end
  
    def rubygems_lib_dir
      "#{rubygems_dist_dir}/lib"
    end
  
    def rubygems_bin_dir
      "#{rubygems_dist_dir}/bin"
    end
  
    def test_rubygems_config_file
      file_name = "test_gem.rc"
      File.expand_path(File.dirname(__FILE__) + "/../tmp/#{file_name}")
    end
  
    def sample_gem_name
      "stubgem"
    end

    def sample_gem_version
      "1.0.0"
    end

    def sample_dependent_gem_name
      "dependent-stubgem"
    end

    def sample_dependent_multiplatform_gem_name
      "dependent-stubgem-multiplatform"
    end

    def sample_dependent_depends_on_multiplatform_gem_name
      "dependent-stubgem-depends-on-multiplatform"
    end

    def sample_dependent_gem_version
      "1.0.0"
    end

    def sample_dependent_multilevel_gem_name
      "dependent-stubgem-multilevel"
    end

    def sample_multiplatform_gem_name
      "stubgem-multiplatform"
    end

    def sample_multiplatform_gem_version_low
      "1.0.0"
    end
  
    def sample_multiplatform_gem_version
      "1.0.1"
    end
  
    def embedded_gem_server_port
      9909
    end

    def embedded_gem_server_url
      "http://127.0.0.1:#{embedded_gem_server_port}"
    end
  
    def install_options_for_testing
      ['--backtrace','--source', embedded_gem_server_url, '--config-file', test_rubygems_config_file]
    end
    
    def uninstall_options_for_testing
      ['--backtrace', '--all', '--ignore-dependencies', '--executables', '--config-file', test_rubygems_config_file]
    end
    
    def sample_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def sample_dependent_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_dependent_gem_name, :version => sample_dependent_gem_version, :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def sample_dependent_multilevel_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_dependent_multilevel_gem_name, :version => sample_dependent_gem_version, :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def sample_dependent_depends_on_multiplatform_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_dependent_depends_on_multiplatform_gem_name, :version => sample_dependent_gem_version, :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def sample_multiplatform_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_multiplatform_gem_name, :version => sample_multiplatform_gem_version, :platform => 'mswin32', :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def sample_multiplatform_gem_ruby(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      gem = sample_multiplatform_gem(install_options, uninstall_options)
      gem.platform = 'ruby'
      gem
    end

    def sample_dependent_multiplatform_gem(install_options=install_options_for_testing, uninstall_options=uninstall_options_for_testing)
      GemInstaller::RubyGem.new(sample_dependent_multiplatform_gem_name, :version => sample_multiplatform_gem_version_low, :platform => 'mswin32', :install_options => install_options, :uninstall_options => uninstall_options)
    end
  
    def proc_should_raise_with_message(message_regex, &block)
      error = nil
      lambda {
        begin
          block.call
        rescue GemInstaller::GemInstallerError => error
          raise error
        end
        }.should raise_error(GemInstaller::GemInstallerError)
        error.message.should match(message_regex)
    end
  end
  end
end

class MockStderr
  attr_reader :err
  def write(out)
  end
  
  def print(err)
    @err = err
  end
end

class MockStdout
  attr_reader :out
  def write(out)
  end
  
  def print(out)
    @out = out
  end
end
