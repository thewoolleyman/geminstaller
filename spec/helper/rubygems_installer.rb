module GemInstaller
  class RubyGemsInstaller
    attr_writer :gem_home_dir
    attr_writer :rubygems_dist_dir
    
    def set_gem_home
    end

    def install_sources
      rubygems_dist_dir = File.expand_path(@rubygems_dist_dir)
      Dir.chdir("#{rubygems_dist_dir}/pkgs/sources") do
        load "sources.gemspec"
        spec = Gem.sources_spec
        require 'rubygems/builder'
        gem_file = Gem::Builder.new(spec).build
        require 'rubygems/installer'
        Gem::Installer.new(gem_file).install(true, Gem.dir, false)
      end
      print "Installed RubyGems Sources Gem\n"
    end
  end
end