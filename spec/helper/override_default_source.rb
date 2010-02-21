module GemInstaller
  class OverrideDefaultSource
    def self.override_default_gem_source
      # required - in multiple places - to get rid of default rubygems.org source
      Gem.module_eval do
        def self.default_sources
          ["http://127.0.0.1:9909"]
        end
      end
      Gem.sources = ["http://127.0.0.1:9909"]
    end
  end
end