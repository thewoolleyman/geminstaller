module GemInstaller
  class GemListChecker
    attr_writer :gem_command_manager, :gem_arg_processor, :version_specifier
    
    def find_remote_matching_gem(gem)
      gem_list_match_regexp =  /^#{gem.regexp_escaped_name} \(.*/
      common_args = @gem_arg_processor.strip_non_common_gem_args(gem.install_options)
      remote_list = @gem_command_manager.list_remote_gem(gem, common_args)

      matched_lines = []
      remote_list.each do |line|
        if line.match(gem_list_match_regexp)
          matched_lines << line
        end
      end
      
      if matched_lines.size > 1
        error_message = "Error: more than one remote gem matches (this should not happen and is probably a bug in geminstaller).  Gem name = '#{gem.name}', install options = '#{gem.install_options}'.  Matching remote gems: \n"
        matched_lines.each do |line|
          error_message += line + "\n"
        end
        raise GemInstaller::GemInstallerError.new(error_message)
      end

      if matched_lines.size == 0
        error_message = "Error: Could not find remote gem to install.  Gem name = '#{gem.name}', Gem version = '#{gem.version}', install options = '#{gem.install_options}'"
        raise GemInstaller::GemInstallerError.new(error_message)
      end

      return matched_lines[0]
    end
    
    def verify_and_specify_remote_gem!(gem)
      # TODO: this seems like it is a hack, but we must have a non-ambiguous version on the gem in order for 
      # noninteractive_chooser to be able to parse the gem list for multi-platform gems.  This will not be necessary
      # if a future RubyGems release allows specification/searching of the platform, because then we won't need noninteractive_chooser
      
      version_list = available_versions(gem)
      specified_version = @version_specifier.specify(gem.version, version_list, gem.name)
      gem.version = specified_version
    end

    def available_versions(gem)
      remote_match_line = find_remote_matching_gem(gem)
      version_list = parse_out_version_list(remote_match_line)
    end
    
    def parse_out_version_list(line)
      # return everything between first set of parenthesis
      version_list = line.split(/[()]/)[1]
      version_list
    end
        
  end
end
