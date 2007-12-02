module GemInstaller
  class RubyGemsInstaller
    attr_writer :gem_home_dir
    attr_writer :rubygems_dist_dir
    
    def set_gem_home
    end

    def install_sources
      gem_home_dir = File.expand_path(@gem_home_dir)
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      ENV['GEM_HOME'] = gem_home_dir
      Dir.chdir("#{rubygems_dist_dir}/pkgs/sources") do
        load "sources.gemspec"
        spec = Gem.sources_spec
        require 'rubygems/builder'
        gem_file = Gem::Builder.new(spec).build
        require 'rubygems/installer'
        Gem::Installer.new(gem_file).install(true, Gem.dir, false)
      end
      print "Installed RubyGems Sources Gem at #{gem_home_dir}\n"
    end
  end
end