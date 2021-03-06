#!/usr/bin/env ruby
#--
# Copyright 2006 by Chad Fowler, Rich Kilmer, Jim Weirich and others.
# All rights reserved.
# See LICENSE.txt for permissions.
#++

at_exit { $SAFE = 1 }

$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'fileutils'
require 'test/unit'
require 'tmpdir'
require 'uri'
require 'rubygems/package'
require 'rubygems/test_utilities'

require File.join(File.expand_path(File.dirname(__FILE__)), 'mockgemui')

module Gem
  def self.searcher=(searcher)
    MUTEX.synchronize do @searcher = searcher end
  end

  def self.source_index=(si)
    @@source_index = si
  end

  def self.win_platform=(val)
    @@win_platform = val
  end

  module DefaultUserInteraction
    @ui = MockGemUi.new
  end
end

class RubyGemTestCase < Test::Unit::TestCase

  include Gem::DefaultUserInteraction

  undef_method :default_test if instance_methods.include? 'default_test' or
                                instance_methods.include? :default_test

  def setup
    super

    @ui = MockGemUi.new
    tmpdir = nil
    Dir.chdir Dir.tmpdir do tmpdir = Dir.pwd end # HACK OSX /private/tmp
    @tempdir = File.join tmpdir, "test_rubygems_#{$$}"
    @tempdir.untaint
    @gemhome = File.join @tempdir, "gemhome"
    @gemcache = File.join(@gemhome, "source_cache")
    @usrcache = File.join(@gemhome, ".gem", "user_cache")
    @latest_usrcache = File.join(@gemhome, ".gem", "latest_user_cache")
    @userhome = File.join @tempdir, 'userhome'

    ENV['HOME'] = @userhome
    Gem.instance_variable_set :@user_home, nil

    FileUtils.mkdir_p @gemhome
    FileUtils.mkdir_p @userhome

    ENV['GEMCACHE'] = @usrcache
    Gem.use_paths(@gemhome)
    Gem.loaded_specs.clear

    Gem.configuration.verbose = true
    Gem.configuration.update_sources = true

    @gem_repo = "http://gems.example.com/"
    @uri = URI.parse @gem_repo
    Gem.sources.replace [@gem_repo]

    Gem::SpecFetcher.fetcher = nil

    @orig_BASERUBY = Gem::ConfigMap[:BASERUBY]
    Gem::ConfigMap[:BASERUBY] = Gem::ConfigMap[:RUBY_INSTALL_NAME]

    @orig_arch = Gem::ConfigMap[:arch]

    if win_platform?
      util_set_arch 'i386-mswin32'
    else
      util_set_arch 'i686-darwin8.10.1'
    end

    @marshal_version = "#{Marshal::MAJOR_VERSION}.#{Marshal::MINOR_VERSION}"

    @private_key = File.expand_path File.join(File.dirname(__FILE__),
                                              'private_key.pem')
    @public_cert = File.expand_path File.join(File.dirname(__FILE__),
                                              'public_cert.pem')

    Gem.post_install_hooks.clear
    Gem.post_uninstall_hooks.clear
    Gem.pre_install_hooks.clear
    Gem.pre_uninstall_hooks.clear

    Gem.post_install do |installer|
      @post_install_hook_arg = installer
    end

    Gem.post_uninstall do |uninstaller|
      @post_uninstall_hook_arg = uninstaller
    end

    Gem.pre_install do |installer|
      @pre_install_hook_arg = installer
    end

    Gem.pre_uninstall do |uninstaller|
      @pre_uninstall_hook_arg = uninstaller
    end
  end

  def teardown
    Gem::ConfigMap[:BASERUBY] = @orig_BASERUBY
    Gem::ConfigMap[:arch] = @orig_arch

    if defined? Gem::RemoteFetcher then
      Gem::RemoteFetcher.fetcher = nil
    end

    FileUtils.rm_rf @tempdir

    ENV.delete 'GEMCACHE'
    ENV.delete 'GEM_HOME'
    ENV.delete 'GEM_PATH'

    Gem.clear_paths
  end

  def install_gem gem
    require 'rubygems/installer'

    use_ui MockGemUi.new do
      Dir.chdir @tempdir do
        Gem::Builder.new(gem).build
      end
    end

    gem = File.join(@tempdir, "#{gem.full_name}.gem").untaint
    Gem::Installer.new(gem, :wrappers => true).install
  end

  def prep_cache_files(lc)
    @usr_si ||= Gem::SourceIndex.new
    @usr_sice ||= Gem::SourceInfoCacheEntry.new @usr_si, 0

    @sys_si ||= Gem::SourceIndex.new
    @sys_sice ||= Gem::SourceInfoCacheEntry.new @sys_si, 0

    latest_si = Gem::SourceIndex.new
    latest_si.add_specs(*@sys_si.latest_specs)
    latest_sys_sice = Gem::SourceInfoCacheEntry.new latest_si, 0

    latest_si = Gem::SourceIndex.new
    latest_si.add_specs(*@usr_si.latest_specs)
    latest_usr_sice = Gem::SourceInfoCacheEntry.new latest_si, 0

    [ [lc.system_cache_file, @sys_sice],
      [lc.latest_system_cache_file, latest_sys_sice],
      [lc.user_cache_file, @usr_sice],
      [lc.latest_user_cache_file, latest_usr_sice],
    ].each do |filename, data|
      FileUtils.mkdir_p File.dirname(filename).untaint

      open filename.dup.untaint, 'wb' do |f|
        f.write Marshal.dump({ @gem_repo => data })
      end
    end
  end

  def read_cache(path)
    open path.dup.untaint, 'rb' do |io|
      Marshal.load io.read
    end
  end

  def read_binary(path)
    Gem.read_binary path
  end

  def write_file(path)
    path = File.join(@gemhome, path)
    dir = File.dirname path
    FileUtils.mkdir_p dir

    open path, 'wb' do |io|
      yield io
    end

    path
  end

  def quick_gem(gemname, version='2')
    require 'rubygems/specification'

    spec = Gem::Specification.new do |s|
      s.platform = Gem::Platform::RUBY
      s.name = gemname
      s.version = version
      s.author = 'A User'
      s.email = 'example@example.com'
      s.homepage = 'http://example.com'
      s.has_rdoc = true
      s.summary = "this is a summary"
      s.description = "This is a test description"

      yield(s) if block_given?
    end

    path = File.join "specifications", "#{spec.full_name}.gemspec"
    written_path = write_file path do |io|
      io.write(spec.to_ruby)
    end

    spec.loaded_from = written_path

    Gem.source_index.add_spec spec

    return spec
  end

  def util_build_gem(spec)
    dir = File.join(@gemhome, 'gems', spec.full_name)
    FileUtils.mkdir_p dir

    Dir.chdir dir do
      spec.files.each do |file|
        next if File.exist? file
        FileUtils.mkdir_p File.dirname(file)
        File.open file, 'w' do |fp| fp.puts "# #{file}" end
      end

      use_ui MockGemUi.new do
        Gem::Builder.new(spec).build
      end

      FileUtils.mv "#{spec.full_name}.gem",
                   File.join(@gemhome, 'cache', "#{spec.original_name}.gem")
    end
  end

  def util_clear_gems
    FileUtils.rm_r File.join(@gemhome, 'gems')
    FileUtils.rm_r File.join(@gemhome, 'specifications')
    Gem.source_index.refresh!
  end

  def util_gem(name, version, &block)
    spec = quick_gem(name, version, &block)

    util_build_gem spec

    cache_file = File.join @tempdir, 'gems', "#{spec.original_name}.gem"
    FileUtils.mv File.join(@gemhome, 'cache', "#{spec.original_name}.gem"),
                 cache_file
    FileUtils.rm File.join(@gemhome, 'specifications',
                           "#{spec.full_name}.gemspec")

    spec.loaded_from = nil
    spec.loaded = false

    [spec, cache_file]
  end

  def util_gzip(data)
    out = StringIO.new

    Zlib::GzipWriter.wrap out do |io|
      io.write data
    end

    out.string
  end

  def util_make_gems
    init = proc do |s|
      s.files = %w[lib/code.rb]
      s.require_paths = %w[lib]
    end

    @a1 = quick_gem('a', '1', &init)
    @a2 = quick_gem('a', '2', &init)
    @a_evil9 = quick_gem('a_evil', '9', &init)
    @b2 = quick_gem('b', '2', &init)
    @c1_2   = quick_gem('c', '1.2',   &init)
    @pl1     = quick_gem 'pl', '1' do |s| # l for legacy
      s.files = %w[lib/code.rb]
      s.require_paths = %w[lib]
      s.platform = Gem::Platform.new 'i386-linux'
      s.instance_variable_set :@original_platform, 'i386-linux'
    end

    write_file File.join(*%W[gems #{@a1.original_name} lib code.rb]) do end
    write_file File.join(*%W[gems #{@a2.original_name} lib code.rb]) do end
    write_file File.join(*%W[gems #{@b2.original_name} lib code.rb]) do end
    write_file File.join(*%W[gems #{@c1_2.original_name} lib code.rb]) do end
    write_file File.join(*%W[gems #{@pl1.original_name} lib code.rb]) do end

    [@a1, @a2, @a_evil9, @b2, @c1_2, @pl1].each { |spec| util_build_gem spec }

    FileUtils.rm_r File.join(@gemhome, 'gems', @pl1.original_name)

    Gem.source_index = nil
  end

  ##
  # Set the platform to +arch+

  def util_set_arch(arch)
    Gem::ConfigMap[:arch] = arch
    platform = Gem::Platform.new arch

    Gem.instance_variable_set :@platforms, nil
    Gem::Platform.instance_variable_set :@local, nil

    platform
  end

  def util_setup_fake_fetcher
    require 'zlib'
    require 'socket'
    require 'rubygems/remote_fetcher'

    @fetcher = Gem::FakeFetcher.new

    util_make_gems

    @all_gems = [@a1, @a2, @a_evil9, @b2, @c1_2].sort
    @all_gem_names = @all_gems.map { |gem| gem.full_name }

    gem_names = [@a1.full_name, @a2.full_name, @b2.full_name]
    @gem_names = gem_names.sort.join("\n")

    @source_index = Gem::SourceIndex.new
    @source_index.add_spec @a1
    @source_index.add_spec @a2
    @source_index.add_spec @a_evil9
    @source_index.add_spec @c1_2

    Gem::RemoteFetcher.fetcher = @fetcher
  end

  def util_setup_source_info_cache(*specs)
    require 'rubygems/source_info_cache'
    require 'rubygems/source_info_cache_entry'

    specs = Hash[*specs.map { |spec| [spec.full_name, spec] }.flatten]
    si = Gem::SourceIndex.new specs

    sice = Gem::SourceInfoCacheEntry.new si, 0
    sic = Gem::SourceInfoCache.new

    sic.set_cache_data( { @gem_repo => sice } )
    sic.update
    sic.write_cache
    sic.reset_cache_data

    Gem::SourceInfoCache.instance_variable_set :@cache, sic

    si
  end

  def util_setup_spec_fetcher(*specs)
    specs = Hash[*specs.map { |spec| [spec.full_name, spec] }.flatten]
    si = Gem::SourceIndex.new specs

    spec_fetcher = Gem::SpecFetcher.fetcher

    spec_fetcher.specs[@uri] = []
    si.gems.sort_by { |_, spec| spec }.each do |_, spec|
      spec_tuple = [spec.name, spec.version, spec.original_platform]
      spec_fetcher.specs[@uri] << spec_tuple
    end

    spec_fetcher.latest_specs[@uri] = []
    si.latest_specs.sort.each do |spec|
      spec_tuple = [spec.name, spec.version, spec.original_platform]
      spec_fetcher.latest_specs[@uri] << spec_tuple
    end

    si.gems.sort_by { |_,spec| spec }.each do |_, spec|
      path = "#{@gem_repo}quick/Marshal.#{Gem.marshal_version}/#{spec.original_name}.gemspec.rz"
      data = Marshal.dump spec
      data_deflate = Zlib::Deflate.deflate data
      @fetcher.data[path] = data_deflate
    end

    si
  end

  def util_zip(data)
    Zlib::Deflate.deflate data
  end

  def self.win_platform?
    Gem.win_platform?
  end

  def win_platform?
    Gem.win_platform?
  end

  # NOTE Allow tests to use a random (but controlled) port number instead of
  # a hardcoded one. This helps CI tools when running parallels builds on
  # the same builder slave.
  def self.process_based_port
    @@process_based_port ||= 8000 + $$ % 1000
  end

  def process_based_port
    self.class.process_based_port
  end

end

