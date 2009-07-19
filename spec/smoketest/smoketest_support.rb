module GemInstaller
  module SmoketestSupport
    def gem_home
      is_windows = RUBY_PLATFORM =~ /mswin/ ? true : false
      return '' if is_windows
      # dummy command needed or IO.popen chokes on GEM_HOME/GEM_PATH assignment
      return "echo 'dummy command'; GEM_HOME=#{gem_home_dir} GEM_PATH=#{gem_home_dir}"
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
