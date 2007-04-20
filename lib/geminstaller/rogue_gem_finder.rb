module GemInstaller
  class RogueGemFinder
    attr_writer :output_proxy, :gem_command_manager, :gem_spec_manager, :boilerplate_lines, :preinstalled_gem_names, :preinstalled_comment

    def print_rogue_gems(config_gems, config_file_paths)
      @boilerplate_lines ||= default_boilerplate_lines(config_gems, config_file_paths)
      @preinstalled_gem_names ||= default_preinstalled_gem_names
      @preinstalled_comment ||= default_preinstalled_comment
      @config_gems_with_dependencies = []
      config_gems.each do |config_gem|
        process_gem(config_gem)
      end
      all_local_gems = @gem_spec_manager.all_local_gems
      rogue_gems = []
      all_local_gems.each do |local_gem|
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
      yaml = format_to_yaml(rogue_gems)
      
      handle_output(yaml)
    end
    
    def default_boilerplate_lines(config_gems, config_file_paths)
      boilerplate = []
      boilerplate <<  [
        "#",
        "# This is a GemInstaller config file (http://geminstaller.rubyforge.org)",
        "# It was generated using the 'geminstaller --print-rogue-gems' option on #{Time.now}",
        "#",
        "# You can bootstrap your config by piping the output to a file: ",
        "#   'geminstaller --print-rogue-gems > geminstaller.yml'",
        "#",
        "# You can then install these gems on another system by running geminstaller with this file.",
        "#"
      ]
      
      if config_file_paths.size == 0
        boilerplate << "# Since there was no config file specified, the 'gems:' section below lists all gems on your system."
      else
        boilerplate << "# The following config file(s) and gems were already specified:"
        boilerplate << "#   Files:"
        config_file_paths.each do |config_file_path|
          boilerplate << "#     * " + config_file_path
        end
        boilerplate << "#   Gems:"
        if config_gems.size > 0
          config_gems.each do |config_gem|
            boilerplate << "#     * #{config_gem.name} #{config_gem.version}"
          end
        else
          boilerplate << "#     No Gems"
        end
      end
      boilerplate << "#"
      boilerplate << "defaults:"
      boilerplate << "  install_options: --include-dependencies"
      return boilerplate
    end
    
    def default_preinstalled_gem_names
      # This is the list of preinstalled gems from the Ruby windows 1-click installer, v186-25
      # 
      # fxri (0.3.6)
      #     Graphical interface to the RI documentation, with search engine.
      # 
      # fxruby (1.6.6)
      #     FXRuby is the Ruby binding to the FOX GUI toolkit.
      # 
      # hpricot (0.4)
      #     a swift, liberal HTML parser with a fantastic library
      # 
      # log4r (1.0.5)
      #     Log4r is a comprehensive and flexible logging library for Ruby.
      # 
      # rake (0.7.2)
      #     Ruby based make-like utility.
      # 
      # sources (0.0.1)
      #     This package provides download sources for remote gem installation
      # 
      # win32-clipboard (0.4.1)
      #     A package for interacting with the Windows clipboard
      # 
      # win32-dir (0.3.1)
      #     Extra constants and methods for the Dir class on Windows.
      # 
      # win32-eventlog (0.4.3)
      #     Interface for the MS Windows Event Log.
      # 
      # win32-file (0.5.3)
      #     Extra or redefined methods for the File class on Windows.
      # 
      # win32-file-stat (1.2.3)
      #     A File::Stat class tailored to MS Windows
      # 
      # win32-process (0.5.1)
      #     Adds fork, wait, wait2, waitpid, waitpid2 and a special kill method
      # 
      # win32-sapi (0.1.3)
      #     An interface to the MS SAPI (Sound API) library.
      # 
      # win32-sound (0.4.0)
      #     A package for playing with sound on Windows.
      # 
      # windows-pr (0.6.2)
      #     Windows functions and constants predefined via Win32API

      if RUBY_PLATFORM =~ /mswin/
        return [
          'fxri',
          'fxruby',
          'hpricot',
          'log4r',
          'rake',
          'sources',
          'win32-clipboard',
          'win32-dir',
          'win32-eventlog',
          'win32-file',
          'win32-file-stat',
          'win32-process',
          'win32-sapi',
          'win32-sound',
          'windows-pr'
        ]
      end
      return ['sources']
    end
    
    def default_preinstalled_comment
      "# NOTE: This gem may have been automatially installed with Ruby, and not actually be used by your app(s)."
    end
    
    def handle_output(yaml)
      yaml_lines = yaml.split("\n")
      yaml_doc_separator = yaml_lines.delete_at(0)
      
      output = []
      output.push(yaml_doc_separator)
      
      output << @boilerplate_lines
      
      yaml_lines.each do |yaml_line| 
        name_parser_regexp = /- name: (.*)/
        yaml_line =~  name_parser_regexp
        gem_name = $1
        preinstalled_comment = ''
        if @preinstalled_gem_names.include?(gem_name)
          preinstalled_comment = " " + @preinstalled_comment
        end
        output.push yaml_line + preinstalled_comment
      end
      
      output_string = output.join("\n")
      @output_proxy.sysout output_string
      output_string
    end
    
    def process_gem(gem)
      @config_gems_with_dependencies << gem
      process_gem_dependencies(gem)
    end

    def process_gem_dependencies(gem)
      # TODO: this method is duplicated in autogem  Should abstract and take a block
      matching_gems = @gem_spec_manager.local_matching_gems(gem)
      matching_gems.each do |matching_gem|
        dependency_gems = @gem_command_manager.dependency(matching_gem.name, matching_gem.version.to_s)
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