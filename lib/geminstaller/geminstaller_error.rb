module GemInstaller
  class GemInstallerError < RuntimeError
    def descriptive_exit_message(message, command, args, listener)
      args_string = args.join(" ")
      descriptive_exit_message = "\n=========================================================\n"
      descriptive_exit_message += "#{message}\n"
      descriptive_exit_message += "Gem command was:\n  #{command} #{args_string}\n\n"
      descriptive_exit_message += "Gem command output was:\n"
      descriptive_exit_message += listener.read!.join("\n")
      descriptive_exit_message += "\n=========================================================\n\n"
    end
  end
end