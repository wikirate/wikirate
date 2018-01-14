# -*- encoding : utf-8 -*-
source "http://rubygems.org"

# decko_gem_path = ENV["WIKIRATE_DECKO_GEM_PATH"] || "./vendor/decko"
decko_gem_path = "./vendor/decko"

if ENV["RM_INFO"] && ARGV[0] == 'check'
  puts "Execution in RubyMine detected in Gemfile. Ignoring decko gem path"
  # This causes Rubymine and IntelliJ to handle these paths as normal sources rather
  # than gems or libraries.
  # That way the files are included as normal project sources in Find and Open.
else
  path decko_gem_path do
    gem "card", require: false
    gem "cardname", require: false
    gem "decko"
  end
end

gem "mysql2", "~> 0.3.18"

gem "bulk_insert"
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
gem "pdfkit"
gem "roo"
gem "wbench"
gem "wkhtmltopdf-binary"

gem "rubocop"
gem "rubocop-decko"

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
  gem "rspec-rails", "~> 3.6.1" # 3.7.0 broke stuff!
  # gem 'wagn-rspec-formatter',  git: 'https://github.com/xithan/wagn-rspec-formatter.git'

  gem "simplecov", require: false
  gem "spork", ">=0.9"

  gem "timecop"
  # gem 'codeclimate-test-reporter', require: nil

  # CUKES see features dir
  #gem "chromedriver-helper"
  gem "geckodriver-helper"
  gem "cucumber-rails", require: false
  # feature-driven-development suite
  gem "capybara", "2.17.0"
  gem "selenium-webdriver", "3.8.0"
  # gem 'capybara-webkit' # lets cucumber launch browser windows
  gem "launchy"

  gem "email_spec"
  # used by cucumber for db transactions
  gem "database_cleaner", "~> 1.4.1"

  gem "minitest"
end

group :development do
  gem 'html2haml'
  gem "rubocop-rspec"

  gem "rails-dev-tweaks"
  gem "sprockets" # just so above works

  gem "capistrano"
  gem "capistrano-bundler"
  gem 'capistrano-git-with-submodules', '~> 2.0'
  gem "capistrano-maintenance", require: false
  gem "capistrano-passenger"
  gem "capistrano-rvm"
  gem 'pivotal-tracker'

  gem "better_errors"
  gem "binding_of_caller"

  # gem "spring"
  # gem 'spring-commands-rspec'
  #

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
