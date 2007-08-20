module GemInstaller
  class RubyGemsInstaller
    attr_writer :install_dir
    attr_writer :rubygems_dist_dir
    
    def install
      print "Installing RubyGems...\n"
      install_dir = File.expand_path(@install_dir)
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      ENV['GEM_HOME'] = "#{install_dir}"
      setup_cmd = "ruby setup.rb"
      Dir.chdir("#{rubygems_dist_dir}") do
        `#{setup_cmd} --quiet config --prefix=#{install_dir}`
        `#{setup_cmd} --quiet setup`
        `#{setup_cmd} --quiet install`
      end
      print "Installed RubyGems at #{install_dir}\n"
    end
  end
end