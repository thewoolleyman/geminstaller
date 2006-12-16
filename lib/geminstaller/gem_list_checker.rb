module GemInstaller
  class GemListChecker
    attr_writer :gem_command_manager, :gem_arg_processor
    
    def gem_exists_remotely?(gem)
      regexp_escaped_gem_name = Regexp.escape(gem.name)
      gem_list_match_regexp =  /^#{regexp_escaped_gem_name} \(.*/
      list_command_args = @gem_arg_processor.strip_non_common_gem_args(gem.install_options)
      remote_list = @gem_command_manager.list_remote_gem(gem, list_command_args)
      
      remote_list.each do |line|
        if line.match(gem_list_match_regexp)
          return true
        end
      end

      return false
    end
  end
end
