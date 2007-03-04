module GemInstaller
  class MissingDependencyFinder
    def find(gems)
      gem1 = GemInstaller::RubyGem.new("stubgem", :version => "1.0")
      gem2 = GemInstaller::RubyGem.new("stubgem-multiplatform", :version => "1.0")
      missing_dependencies = [gem1, gem2]
      return missing_dependencies
    end
  end
end