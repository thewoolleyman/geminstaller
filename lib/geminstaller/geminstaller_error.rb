module GemInstaller
  class GemInstallerError < RuntimeError
    def descriptive_exit_message(message, command, args, gem_command_output)
      args_string = args.join(" ")
      descriptive_exit_message = "\n=========================================================\n"
      descriptive_exit_message += "#{message}\n"
      descriptive_exit_message += "Gem command was:\n  #{command} #{args_string}\n\n"
      descriptive_exit_message += "Gem command output was:\n"
      descriptive_exit_message += gem_command_output.join("\n")
      descriptive_exit_message += "\n=========================================================\n\n"
    end
  end
end