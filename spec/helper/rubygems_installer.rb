module GemInstaller
  class RubyGemsInstaller
    attr_writer :install_dir
    attr_writer :test_gem_home_dir
    attr_writer :siteruby_dir
    attr_writer :siterubyver_dir
    attr_writer :libruby_dir
    attr_writer :rubygems_dist_dir
    
    def install
      print "Installing RubyGems...\n"
      install_dir = File.expand_path(@install_dir)
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      ENV['GEM_HOME'] = "#{install_dir}"
      setup_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_dist_dir} setup.rb"
      Dir.chdir("#{rubygems_dist_dir}") do
        `#{setup_cmd} --quiet config --prefix=#{install_dir} --libruby=#{libruby_dir} --siteruby=#{siteruby_dir} --siterubyver=#{siterubyver_dir}`
        `#{setup_cmd} --quiet setup`
        `#{setup_cmd} --quiet install`
      end
      print "Installed RubyGems at #{install_dir}\n"
    end
  end
end