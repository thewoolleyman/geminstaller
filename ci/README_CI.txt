Use these steps to run GemInstaller under CruiseControl.rb:

* Create project with name 'geminstaller_using_rubygems_x-y-z', where 'x-y-z' is the version of RubyGems to test against.

* symlink geminstaller/ci/cruise to /etc/init.d/cruise and follow instructions it contains to hook up init script and update-rc.d.

* gem install mongrel and daemons (TODO: add these to geminstaller config)

* Edit ~/.cruise/site_config.rb to have the following entries:

# builds must run in serial for now, to prevent conflicts
Configuration.serialize_builds = true
 
# use dedicated gmail account for mailing
ActionMailer::Base.smtp_settings = {
  :address =>        "smtp.gmail.com",
  :port =>           587,
  :domain =>         "thewoolleyweb.com",
  :authentication => :plain,
  :user_name =>      "thewoolleyweb.smtp",
  :password =>       "????"
}
