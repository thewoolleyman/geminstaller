module GemInstaller::SpecUtils

  def local_gem_server_required_warning
    "Warning: If this test fails with an error like 'connection refused', you need to make a copy of your .../ruby/gems/1.8 directory to another dir, and run 'gem_server --dir=<otherdir>'.  Or, set skip_gem_server_functional_tests? to true in spec_utils."  
  end
  
  def sample_gem_name
    sample_gem_name = "ruby-doom"
  end

  def sample_gem_version
    sample_gem_version = "0.8"
  end

  def local_gem_server_url
    "http://127.0.0.1:8808"
  end
  
  def skip_gem_server_functional_tests?
    false
  end
  
  def source_param
    ["--source", local_gem_server_url]
  end
  
  def sample_gem(install_options=source_param)
    GemInstaller::RubyGem.new(sample_gem_name, :version => sample_gem_version, :install_options => install_options)
  end
end