module GemInstaller
  # Format for "install" prompt list: "#{spec.name} #{spec.version} (#{spec.platform})"
  # Format for "uninstall" prompt list: "#{spec.name}-#{spec.version} (#{spec.platform})"
  class NoninteractiveChooser
    attr_writer :gem_source_index_proxy
    
    def specify_exact_gem_spec(name, version, platform)
      @required_name = name
      @required_version = version
      @required_platform = platform
    end
    def choose(list)
      required_list_item = "#{Regexp.escape(@required_name)}.#{Regexp.escape(@required_version)}"
      if (@required_platform)
        required_list_item += Regexp.escape(" (#{@required_platform})")
      end
      required_list_item_regex = /^#{required_list_item}$/
      list.each_with_index do |item, index|
        if (item =~ required_list_item_regex) != nil
          return item, index
        end
      end
      return nil, nil
    end
  end
end
