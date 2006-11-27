geminstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org

== DESCRIPTION:
  
Automatically installs RubyGems required by your project.

== FEATURES/PROBLEMS:
  
* Tired of manually installing gems on multiple environments?  Let GemInstaller do it for you automatically.

== SYNOPSYS:

GemInstaller is a tool to automatically install RubyGems.  To use it, edit "geminstaller.yml", and run "geminstaller" from the same directory.

Here's an example geminstaller.yml:

defaults:
  install_options: -y
gems:
  - name: some-gem
    version: 0.1
    install_options: -y --backtrace --source=http://gems.myreliableserver.com:8808
  - name: another-gem
    version: 0.2

You can also embed GemInstaller in another application, such as a Rails app.  Create geminstaller.yml in the RAILS_ROOT, and invoke GemInstaller programatically on app startup in your environment.rb:

RAILS_ROOT/config/environment.rb:
...
require "geminstaller"
GemInstaller.run
...

== REQUIREMENTS:

* needle
* rubygems

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
