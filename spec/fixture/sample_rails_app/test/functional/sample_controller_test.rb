require File.dirname(__FILE__) + '/../test_helper'

class SampleControllerTest < ActionController::TestCase
  def test_geminstaller
    sample_gem_name = 'ruby-doom-0.8'
    sample_gem_loaded = false
    $:.each do |path_element|
      if path_element =~ /#{sample_gem_name}/
        sample_gem_loaded = true
        break
      end
    end
    assert(sample_gem_loaded,
          "FAILURE, GemInstaller.autogem did not put sample gem #{sample_gem_name} on load path: #{$:}") 
  end
end
