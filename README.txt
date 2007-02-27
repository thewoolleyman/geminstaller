GemInstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org

== DESCRIPTION:
  
Automatically installs Ruby Gems.

== FEATURES:
  
* Tired of manually installing and upgrading Ruby Gems for multiple machines, platforms, or environments?  Let GemInstaller do it for you automatically!

== SYNOPSYS:

GemInstaller is a tool to automatically install Ruby Gems.  

=== Download:

Downloads are available at http://rubyforge.org/frs/?group_id=1902

=== Basic Usage:

To use GemInstaller, edit "geminstaller.yml", and run "geminstaller" from the same directory.

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

Create geminstaller.yml in the RAILS_ROOT/config directory, and invoke GemInstaller on app startup in your boot.rb.  It should be placed right after the block which defines the RAILS_ROOT constant, as shown below ("..." indicates omitted lines):

==== Invoking the GemInstaller class:

RAILS_ROOT/config/boot.rb:
	...
	unless defined?(RAILS_ROOT)
	...
	end

    # this is the Rails GemInstaller setup if you DON'T require root access to install gems
	require "rubygems"
	require "geminstaller"
	args = ["--info","--config=#{RAILS_ROOT}/config/geminstaller.yml"]
	GemInstaller.run(args)

	unless defined?(Rails::Initializer)
	...

==== Invoking the GemInstaller executable:

RAILS_ROOT/config/boot.rb:
	...
	unless defined?(RAILS_ROOT)
	...
	end

    # this is the Rails GemInstaller setup if you DO require root access to install gems
	system "geminstaller --sudo --info --config=#{RAILS_ROOT}/config/geminstaller.yml"

	unless defined?(Rails::Initializer)
	...

=== "check_for_upgrade" option

You can specify the "check_for_upgrade" boolean option for any gem, or as the default.  This will cause geminstaller to install the latest version of the gem, if there is a more recent version available at the specified source.  check_for_upgrade is true by default, so geminstaller will always install the latest versions of all gems by default.  If you don't want this, then set it to false in the defaults section.  You may also want check_for_upgrade to be false by default if you will be working without a network connection - on a laptop, for example.

Here's an example geminstaller.yml which will disable upgrade checking for all gems but one:

	defaults:
	  check_for_upgrade: false
	gems:
	  - name: some-gem
	  - name: my-bleeding-edge-gem
	    check_for_upgrade: true

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

A transparent solution to this problem is planned as an enhancement to a future release of GemInstaller.  For now, however, you will need to pick one of the following approaches below.  If you use sudo, you should also read the tops on configuring sudo.

==== Option 1 - Use the -s  or --sudo option on the geminstaller executable

Examples:
$ geminstaller -s
$ geminstaller --sudo

==== Option 2 - Run sudo or log in as root yourself

Example of using sudo:
$ sudo geminstaller

Example of running geminstaller as root
$ su - 
# geminstaller

==== Option 3 - Make everything owned by the local user that runs geminstaller

(replace <local user> with your username)
$ cd /usr/local/lib/ruby # or wherever you have ruby installed
$ sudo chown -R <local user> .

==== Tips on configuring sudo

Sudo can be configured to not ask for a password for certain commands.  This will be useful if you want to run geminstaller against a root-owned gem repository without being prompted (such as a Rails app being deployed via Capistrano).

You should consult the man or info pages on sudoers and visudo for more info (man sudoers, info sudoers).  *** Make sure you understand the security implications of this approach ***.  

Here's an example of how sudoers might be configured to allow the local user to run the 'gem', 'ruby', and 'geminstaller' commands via sudo without being prompted for a password.  Replace <local user> with your username, and replace '/usr/local/bin/' with the appropriate path if it is different on your system:

$ sudo visudo
add this line:
<local user> ALL = NOPASSWD: /usr/local/bin/geminstaller, /usr/local/bin/ruby, /usr/local/bin/gem

=== Feedback:

==== Bug/Feature Tracker
* http://rubyforge.org/tracker/?group_id=1902

==== Mailing Lists
* http://rubyforge.org/mail/?group_id=1902

==== RubyForge Page
* http://rubyforge.org/projects/geminstaller/


== REQUIREMENTS:

Runtime:
* None. There are no dependencies required to run GemInstaller, other than an installation of RubyGems itself

Building/Testing:
After installing the geminstaller gem (via 'gem install geminstaller'), change to the root of the geminstaller source tree, and run 'geminstaller' to auto-install these:
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
