module GemInstaller
  module SmoketestSupport
    def gem_home
      is_windows = RUBY_PLATFORM =~ /mswin/ ? true : false
      return '' if is_windows
      return "export GEM_HOME=#{gem_home_dir};"
    end
    
    def gem_home_dir
      "#{ENV['HOME']}/.geminstaller_smoketest_gem_home"
    end
  end
end
