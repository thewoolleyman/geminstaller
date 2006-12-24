geminstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org

== DESCRIPTION:
  
Automatically installs RubyGems required by your project.

== FEATURES/PROBLEMS:
  
* Tired of manually installing and upgrading gems on multiple environments?  Let GemInstaller do it for you automatically.

== SYNOPSYS:

GemInstaller is a tool to automatically install RubyGems.  To use it, edit "geminstaller.yml", and run "geminstaller" from the same directory.

Here's an simple example geminstaller.yml:

	defaults:
	  install_options: -y
	gems:
	  - name: some-gem
	    version: '0.1'
	    install_options: -y --backtrace --source=http://gems.myreliableserver.com:8808
	  - name: another-gem
	    version: '0.2'

GemInstaller can also be embedded in another application, such as a Rails app.  Create geminstaller.yml in the RAILS_ROOT/config directory, and invoke GemInstaller programatically on app startup in your environment.rb:

RAILS_ROOT/config/environment.rb:
	...
	require "geminstaller"
	args = ['--info']
	GemInstaller.run(args)
	...


You can also have multiple or custom-named config files, using the '--config' option.  This is useful if you have multiple projects, and want them to share a common config file, but still have project-specific overrides.  The last ones in the list will override the first ones.  For example: 

	'geminstaller --config=../common-config/geminstaller-common-across-projects.yml,geminstaller-custom-for-myproject.yml


The config files are also run through erb, so you can embed any custom ruby code to dynamically generate portions of your config.

Here is a working example with two config files, which use real rubygems from rubyforge.org.  You should be able to run this.  This exact example can also be run by spec/smoketest/smoketed.rb.

	'geminstaller --info --config=smoketest-geminstaller.yml,smoketest-geminstaller-override.yml'

smoketest-geminstaller.yml:
	defaults:
	  install_options: --include-dependencies
	gems:
	  - name: rutils
	    version: '> 0.1.5'
	    platform: ruby

smoketest-geminstaller-override.yml
	defaults:
	gems:
	  - name: rutils
	    version: '0.1.3'
	    platform: ruby
	  - name: ruby-doom
	    version: 0.8
	  - name: x10-cm17a
	    version: '> 1.0.0'
	    platform: <%= RUBY_PLATFORM == 'i386-mswin32' ? 'i386-mswin32' : 'ruby'%>

Thats is for the docs for now.  More to come later.  Please report any bugs/feedback on the GemInstaller rubyforge page:  
  
== REQUIREMENTS:

Runtime:
* nothing, other than rubygems itself

Building/Testing (Run geminstaller in the geminstaller root to auto-install these):
* rake >= 0.7.1
* hoe >= 1.1.6
* rspec >= 0.7.5
* diff-lcs >= 1.1.2
* rcov >= 0.7.0.1

== INSTALL:

* sudo gem install geminstaller

== LICENSE:

(The MIT License)

Copyright (c) 2006 Chad Woolley

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
