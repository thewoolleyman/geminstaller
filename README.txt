GemInstaller
    by Chad Woolley
    http://geminstaller.rubyforge.org

== DESCRIPTION:
  
GemInstaller provides automated management of RubyGems.

== FEATURES:
  
GemInstaller provides automated management of RubyGems.  It uses a simple YAML config file to:

* Automatically install the correct versions of all required gems wherever your app runs.
* Automatically ensure installed gems and versions are consistent across multiple applications, machines, platforms, and environments 
* Automatically add correct versions of gems to the ruby load path when your app runs ('require_gem'/'gem')
* Automatically reinstall missing dependency gems
* Automatically guess at correct platform to install for multi-platform gems
* Print YAML for "rogue gems" which are not specified in the current config, to easily bootstrap your config file, or find gems that were manually installed without GemInstaller.
* Avoid the "works on demo, broken on production" syndrome

== SYNOPSYS:

GemInstaller provides automated management of RubyGems.

=== Download:

Downloads are available at http://rubyforge.org/frs/?group_id=1902

=== Quick Start:

See http://geminstaller.rubyforge.org/documentation/index.html

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
