module GemInstaller
  class RogueGemFinder
    attr_writer :output_proxy, :gem_command_manager

    def print_rogue_gems(config_gems)
      @config_gems_with_dependencies = []
      config_gems.each do |config_gem|
        process_gem(config_gem)
      end
      all_local_gems = @gem_command_manager.all_local_gems
      rogue_gems = []
      all_local_gems.each do |local_gem|
        # "sources" gem is installed with rubygems distribution, so we ignore it
        next if local_gem.name == 'sources'
        config_match_found_for_local = false
        @config_gems_with_dependencies.each do |config_gem|
          name_matches = config_gem.name == local_gem.name
          config_gem_version_requirement = Gem::Version::Requirement.new [config_gem.version]
          local_gem_version = Gem::Version.new(local_gem.version)
          version_matches = config_gem_version_requirement.satisfied_by?(local_gem_version)
          if (name_matches and version_matches)
            config_match_found_for_local = true
            break
          end
        end
        rogue_gems << local_gem unless config_match_found_for_local
      end
      output = format_to_yaml(rogue_gems)
      
      @output_proxy.sysout("====== Rogue Gems - installed but not matched by GemInstaller config ======\n")
      @output_proxy.sysout(output)
      @output_proxy.sysout("===========================================================================\n")
    end
    
    def process_gem(gem)
      @config_gems_with_dependencies << gem
      process_gem_dependencies(gem)
    end

    def process_gem_dependencies(gem)
      # TODO: this method is duplicated in autogem  Should abstract and take a block
      matching_gem_specs = @gem_command_manager.local_matching_gem_specs(gem)
      matching_gem_specs.each do |matching_gem_spec|
        dependency_gems = @gem_command_manager.dependency(matching_gem_spec.name, matching_gem_spec.version.to_s)
        dependency_gems.each do |dependency_gem|
          process_gem(dependency_gem)
        end
      end
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