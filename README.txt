GemInstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org

== DESCRIPTION:
  
Automatically installs Ruby Gems.

== FEATURES:
  
* Tired of manually installing and upgrading Ruby Gems for multiple machines, platforms, or environments?  Let GemInstaller do it for you automatically!

== SYNOPSYS:

GemInstaller is a tool to automatically install Ruby Gems.  To use it, edit "geminstaller.yml", and run "geminstaller" from the same directory.

=== Simple Example:

Here's an simple example geminstaller.yml:

	defaults:
	  install_options: -y
	gems:
	  - name: some-gem
	    version: '0.1'
	    install_options: -y --backtrace --source=http://gems.myreliableserver.com:8808
	  - name: another-gem
	    version: '0.2'

=== Using GemInstaller with Ruby on Rails or other Ruby apps:

GemInstaller can also be embedded in another application, such as a Rails app.  This is done by invoking the GemInstaller class or the geminstaller executable directly from Ruby.  

IMPORTANT NOTE: The approach you use will mainly be determined by whether you run on unix and need root/sudo access to install gems and/or gem executables.  If this is the case, you will probably have to use the second approach below, of invoking the geminstaller executable, rather than calling the geminstaller class directly.  See the section below on dealing with sudo for more details.

Create geminstaller.yml in the RAILS_ROOT/config directory, and invoke GemInstaller programatically on app startup in your environment.rb:

==== Invoking the GemInstaller class:

RAILS_ROOT/config/environment.rb:
	...
	require "geminstaller"
	args = ['--info','--config=config/geminstaller.yml']
	GemInstaller.run(args)
	...

==== Invoking the GemInstaller executable:

RAILS_ROOT/config/environment.rb:
	...
	require "geminstaller"
	TODO: finish this.
	...


=== Multiple Config Files:

You can also have multiple or custom-named config files, using the '--config' option.  This is useful if you have multiple projects, and want them to share a common config file, but still have project-specific overrides.  The last ones in the list will override the first ones.  For example: 

	'geminstaller --config=../common-config/geminstaller-common-across-projects.yml,geminstaller-custom-for-myproject.yml

=== Multiple Config Files:

The GemInstaller config file(s) are also run through erb, so you can embed any custom ruby code to dynamically generate portions of your config.  This can be used to have the same config file select gems differently on different platforms or environments.  For example:

geminstaller-detect-platform.yml
	gems:
	  - name: x10-cm17a
	    version: '> 1.0.0'
	    platform: <%= RUBY_PLATFORM == 'i386-mswin32' ? 'i386-mswin32' : 'ruby'%>

=== A Real Working Example:

Here is a real working example with two config files, which use real rubygems from rubyforge.org.  You should be able to run this.  This exact example can also be run by spec/smoketest/smoketest.rb.

	'geminstaller --info --config=smoketest-geminstaller.yml,smoketest-geminstaller-override.yml'

smoketest-geminstaller.yml:
	defaults:
	  install_options: --include-dependencies
	gems:
	  - name: rutils
	    version: '> 0.1.5'
	    platform: ruby

smoketest-geminstaller-override.yml:
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

=== Dealing with sudo and root-owned RubyGem installations:

If you only run geminstaller on Windows, you don't have to worry about this section :)

On many unix-like systems (Mac, Linux, etc.), the root user will own the local installation of RubyGems and/or the executable directory where gem executables are installed (often /usr/local/bin).  If this is the case, then gems must be installed and uninstalled by the root user, or via the sudo command.  This presents a problem for geminstaller, which must have this same permission to automatically install gems.

There are several different solutions this problem.  The solutions that are available are also determined by the way you use geminstaller (whether you call it from the executable, or use the GemInstaller classes directly from Ruby).

A transparent solution to this problem is planned as an enhancement to a future release of GemInstaller.  For now, however, you will need to pick one of the following approaches:

TODO: fill out examples here:

==== Option 1 - Use the --sudo option on the geminstaller executable

Example:

==== Option 2 - Make everything owned by the local user that runs geminstaller

==== Option 3 - Run sudo yourself

=== Feedback:

That's all the docs for now.  More to come later.  Please report any bugs/feedback on the GemInstaller rubyforge page:  
	http://geminstaller.rubyforge.org

== REQUIREMENTS:

Runtime:
* nothing, other than an installtion of RubyGems itself

Building/Testing (Run the geminstaller executable in the geminstaller root to auto-install these):
* rake >= 0.7.1
* hoe >= 1.1.6
* rspec >= 0.7.5
* diff-lcs >= 1.1.2
* rcov >= 0.7.0.1

== INSTALL:

* [sudo] gem install geminstaller

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
