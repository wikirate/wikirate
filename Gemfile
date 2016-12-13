source "http://rubygems.org"

wagn_gem_path = ENV["WIKIRATE_WAGN_GEM_PATH"] || "./vendor/wagn"

gem "wagn", path: "#{wagn_gem_path}/wagn"
gem "card", path: "#{wagn_gem_path}/card", require: false

gem "statistics2", "0.54"
gem "descriptive_statistics", "2.5.1"
gem "savanna-outliers"

gem "mysql2", "~> 0.3.18"
gem "link_thumbnailer", "2.5.2"
gem "open_uri_redirections"
gem "roo"
gem "wbench"
gem "curb"
gem "daemons"
gem "delayed_job_active_record"
gem "delayed_job_web"
gem "rubocop"
gem "rubocop-decko"

# seems like newrelic should be in :live, but that wasn't working.
# not sure why -efm
gem "newrelic_rpm"
# gem "ruby-prof"
gem "airbrussh", require: false
# gem "spring"

group :live do
  gem "therubyracer"
  gem "dalli"
end

group :test do
  gem "rspec-rails" # behavior-driven-development suite
  gem "rspec", "~> 3.4"
  gem "rspec-html-matchers" # 0.7.0 broke stuff!
  # gem 'wagn-rspec-formatter',  git: 'https://github.com/xithan/wagn-rspec-formatter.git'
  gem "spork", ">=0.9"
  gem "timecop"
  gem "simplecov"
  # gem 'codeclimate-test-reporter', require: nil

  gem "test_after_commit"

  # CUKES see features dir
  gem "cucumber-rails", require: false
  # feature-driven-development suite
  gem "capybara"
  # used 2.0.1
  gem "selenium-webdriver", "~> 2.3"
  #  gem 'capybara-webkit'
  # lets cucumber launch browser windows
  gem "launchy"

  gem "email_spec"
  # used by cucumber for db transactions
  gem "database_cleaner", "~> 1.4.1"

  # Pretty printed test output.
  # (version constraint is to avoid minitest requirement)
  gem "turn", "~>0.8.3", require: false

  gem "minitest"
end

group :development do
  gem "rubocop-rspec"

  gem "rails-dev-tweaks"
  gem "sprockets" # just so above works

  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-rvm"
  gem "capistrano-maintenance", require: false
  gem "capistrano-passenger"
end

group :test, :development do
  gem "thin"
  gem "pry" # , git: 'https://github.com/pry/pry'  # bug in 0.10.3, fixed in
  # master
  gem "pry-rails"
  gem "pry-rescue"
  gem "pry-stack_explorer"
  gem "pry-byebug" if RUBY_VERSION =~ /^2/
end

Dir.glob("mod/**{,/*/**}/Gemfile").each do |gemfile|
  instance_eval(File.read(gemfile))
end
