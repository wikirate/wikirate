# -*- encoding : utf-8 -*-
source "http://rubygems.org"

decko_gem_path = ENV["WIKIRATE_DECKO_GEM_PATH"] || "./vendor/decko"
# decko_gem_path = "./vendor/decko"

gem "card", path: "#{decko_gem_path}/card", require: false
gem "cardname", path: "#{decko_gem_path}/cardname", require: false
gem "decko", path: "#{decko_gem_path}/decko"

gem "mysql2", "~> 0.3.18"

gem "descriptive_statistics" #, "2.5.1"
gem "savanna-outliers"
gem "statistics2" #, "0.54"

gem "curb"
gem "daemons"
gem "delayed_job_active_record"
gem "delayed_job_web"

gem "company-mapping"
gem "link_thumbnailer", "2.5.2"
gem "open_uri_redirections"
gem "roo"
gem "wbench"

gem "rubocop"
gem "rubocop-decko"

gem "pdfkit"
gem "wkhtmltopdf-binary"

gem "fog"
gem "fog-aws"

# seems like newrelic should be in :live, but that wasn't working.
# not sure why -efm
gem "newrelic_rpm"
# gem "ruby-prof"
gem "airbrussh", require: false

gem "ruby-jmeter"

gem "card-mod-airbrake", path: "./vendor/card-mods/airbrake"
gem "card-mod-voting", path: "./vendor/card-mods/voting"
gem "card-mod-logger", path: "./vendor/card-mods/logger"
gem "card-mod-new_relic", path: "./vendor/card-mods/new_relic"
gem "card-mod-pdfjs", path: "./vendor/card-mods/pdfjs"

group :live do
  gem "dalli"
  gem "therubyracer"
end

group :test do
  gem "rspec"
  gem "rspec-html-matchers" # 0.7.0 broke stuff!
  gem "rspec-rails" # behavior-driven-development suite
  # gem 'wagn-rspec-formatter',  git: 'https://github.com/xithan/wagn-rspec-formatter.git'

  gem "simplecov", require: false
  gem "spork", ">=0.9"

  gem "timecop"
  # gem 'codeclimate-test-reporter', require: nil

  # CUKES see features dir
  gem "chromedriver-helper"
  gem "cucumber-rails", require: false
  # feature-driven-development suite
  gem "capybara", "2.11.0"
  # used 2.0.1
  gem "selenium-webdriver", "3.3.0"
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
  gem "capistrano-maintenance", require: false
  gem "capistrano-passenger"
  gem "capistrano-rvm"
  gem 'capistrano-git-with-submodules', '~> 2.0'

  gem "better_errors"
  gem "binding_of_caller"

  gem "spring"
  gem 'spring-commands-rspec'
end

group :test, :development do
  gem "pry"
  gem "pry-byebug"
  gem "pry-rails"
  gem "pry-rescue"
  gem "pry-stack_explorer"
  gem "thin"
end

Dir.glob("mod/**{,/*/**}/Gemfile").each do |gemfile|
  instance_eval(File.read(gemfile))
end
