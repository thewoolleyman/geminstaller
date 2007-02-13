module GemInstaller
  class RubyGemsExit < RuntimeError
    # This is an exception which helps override the normal (no error) system 'exit' call in RubyGems' terminate_interaction 
  end
end