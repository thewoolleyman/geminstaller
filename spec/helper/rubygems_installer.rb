module GemInstaller
  class RubyGemsInstaller
    attr_writer :install_dir
    attr_writer :test_gem_home_dir
    attr_writer :siteruby_dir
    attr_writer :siterubyver_dir
    attr_writer :libruby_dir
    attr_writer :rubygems_dist_dir
    
    def set_gem_home
      ENV['GEM_HOME'] = "#{File.expand_path(@install_dir)}"
    end

    def install
      print "Installing RubyGems...\n"
      install_dir = File.expand_path(@install_dir)
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      set_gem_home
      setup_cmd = "ruby -I #{rubygems_lib_dir}:#{rubygems_dist_dir} setup.rb"
      Dir.chdir("#{rubygems_dist_dir}") do
        `#{setup_cmd} --quiet config --prefix=#{install_dir} --libruby=#{libruby_dir} --siteruby=#{siteruby_dir} --siterubyver=#{siterubyver_dir}`
        `#{setup_cmd} --quiet setup`
        `#{setup_cmd} --quiet install`
      end
      print "Installed RubyGems at #{install_dir}\n"
    end

    def install_sources
      print "Installing Sources Gem (RubyGems < 0.9.5)...\n"
      install_dir = File.expand_path(@install_dir)
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      set_gem_home
      Dir.chdir("#{rubygems_dist_dir}/pkgs/sources") do
        load "sources.gemspec"
        spec = Gem.sources_spec
        require 'rubygems/builder'
        gem_file = Gem::Builder.new(spec).build
        require 'rubygems/installer'
        Gem::Installer.new(gem_file).install(true, Gem.dir, false)
      end
            
      # post_install_path = "#{rubygems_dist_dir}/post-install.rb"
      # Dir.chdir("#{rubygems_dist_dir}") do
      #   instance_eval File.read(post_install_path), post_install_path, 1
      # end
      print "Installed RubyGems Sources Gem at #{install_dir}\n"
    end
  end
end