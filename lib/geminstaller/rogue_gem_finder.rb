module GemInstaller
  class RogueGemFinder
    attr_writer :output_proxy, :gem_command_manager

    def print_rogue_gems(gems_from_config)
      all_local_gems = @gem_command_manager.all_local_gems
      rogue_gems = []
      all_local_gems.each do |local_gem|
        # "sources" gem is installed with rubygems distribution, so we ignore it
        next if local_gem.name == 'sources'
        config_match_found_for_local = false
        gems_from_config.each do |gem_from_config|
          name_matches = gem_from_config.name == local_gem.name
          gem_from_config_version_requirement = Gem::Version::Requirement.new [gem_from_config.version]
          local_gem_version = Gem::Version.new(local_gem.version)
          version_matches = gem_from_config_version_requirement.satisfied_by?(local_gem_version)
          p "local #{local_gem.name}, #{local_gem.version}, config #{gem_from_config.name}, #{gem_from_config.version}, name matches #{name_matches}, version matches #{version_matches}"
          if (name_matches and version_matches)
            config_match_found_for_local = true
            break
          end
        end
        rogue_gems << local_gem unless config_match_found_for_local
      end
      output = format_to_yaml(rogue_gems)
      
      @output_proxy.sysout(output)
    end
    
    def format_to_yaml(gems)
      names_and_versions = []
      gems.each do |gem|
        names_and_versions << {'name' => gem.name, 'version' => gem.version}
      end
      hash_for_yaml = {'gems' => names_and_versions}
      YAML.dump(hash_for_yaml)
    end
  end
end