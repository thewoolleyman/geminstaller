module GemInstaller
  module SmoketestSupport
    def gem_home
      is_windows = RUBY_PLATFORM =~ /mswin/ ? true : false
      return '' if is_windows
      return "export GEM_HOME=#{gem_home_dir}; export GEM_PATH=#{gem_home_dir};"
    end
    
    def gem_home_dir
      "#{ENV['HOME']}/.geminstaller_smoketest_gem_home"
    end

    def remove_gem_home_dir
      require 'fileutils'
      FileUtils.rm_rf(gem_home_dir)
    end
  end
end
