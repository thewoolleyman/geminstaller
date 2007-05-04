dir = File.dirname(__FILE__)
require File.expand_path("#{dir}/geminstaller/requires.rb")

module GemInstaller
  def self.run(args = [], geminstaller_executable = nil)
    args = args.split(' ') unless args.respond_to? :join
    # recursively call script with sudo, if --sudo option is specified
    if platform_supports_sudo? and (args.include?("-s") or args.include?("--sudo"))
      reinvoke_with_sudo(args, geminstaller_executable)
    else
      app = create_application(args)
      app.run
    end
  end 
  
  def self.autogem(config_paths=nil)
    config_paths_string = parse_config_paths(config_paths)
    args = []
    args = ["--config=#{config_paths_string}"] if config_paths_string
    app = create_application(args)
    app.autogem
  end

  def self.version
    "0.0.1"
  end

  def self.create_application(args = [], registry = nil)
    registry ||= create_registry
    app = registry.app
    app.args = args
    app
  end
  
  def self.create_registry
    dependency_injector = GemInstaller::DependencyInjector.new
    dependency_injector.registry
  end
  
  def self.parse_config_paths(config_paths)
    return nil unless config_paths
    return config_paths unless config_paths.respond_to? :join
    return config_paths.join(',')
  end
  
  def self.platform_supports_sudo?
    return true unless RUBY_PLATFORM =~ /mswin/
    return false
  end
  
  def self.reinvoke_with_sudo(args, geminstaller_executable)
    # TODO: this sudo support seems like a hack, but I don't have a better idea right now.  Ideally, we would
    # invoke rubygems from the command line inside geminstaller.  However, we can't do that because rubygems
    # currently doesn't provide a way to specify platform from the command line - it always pops up the list
    # for multi-platform gems, and we have to extend/hack rubygems to manage that.
    # Feel free to comment or improve it, this seems to work for now...
    geminstaller_executable ||= find_geminstaller_executable
    args_without_sudo = args.dup
    args_without_sudo.reject! {|arg| arg == "-s" || arg == "--sudo"}
    cmd = "sudo ruby #{geminstaller_executable} #{args_without_sudo.join(' ')}"
    result = system(cmd)
    return 1 unless result
    return $?.exitstatus
  end
  
  def self.find_geminstaller_executable
    possible_locations = [
      'ruby geminstaller',
      'ruby /usr/local/bin/geminstaller',
      'ruby /usr/bin/geminstaller',
      'ruby ./bin/geminstaller',
      'ruby ./bin/geminstaller'
      ]
    path_key = 'geminstaller_exec_path='
    possible_locations.each do |possible_location|
      cmd = "#{possible_location} --geminstaller-exec-path"
      io = IO.popen(cmd)
      output = io.read
      next unless output =~ /#{path_key}/
      path = output.sub(path_key,'')
      return path
    end
    raise GemInstaller::GemInstallerError.new("Error: Unable to locate the geminstaller executable.  Specify it explicitly, or don't use the sudo option.")
  end
end