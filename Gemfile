source 'http://rubygems.org'

wagn_gem_path = ENV['WIKIRATE_WAGN_GEM_PATH'] || './vendor/wagn'

gem 'wagn', path: "#{wagn_gem_path}/wagn"
gem 'card', path: "#{wagn_gem_path}/card", require: false

gem 'mysql2', '~> 0.3.18'
gem 'link_thumbnailer', '2.5.2'
gem 'open_uri_redirections'
gem 'roo'
gem 'wbench'
gem 'curb'
gem 'daemons'
gem 'delayed_job_active_record'

group :live do
  gem 'therubyracer'
  gem 'dalli'
end

group :test do
  gem 'rspec-rails' # behavior-driven-development suite
  gem 'rspec', '~> 3.4'
  gem 'rspec-html-matchers' # 0.7.0 broke stuff!
  gem 'spork', '>=0.9'
  gem 'timecop'
  gem 'simplecov'
  gem 'codeclimate-test-reporter', require: nil

  # CUKES see features dir
  gem 'cucumber-rails', require: false
  # feature-driven-development suite
  gem 'capybara'
  gem 'selenium-webdriver'
  gem 'launchy'
  # lets cucumber launch browser windows

  gem 'email_spec'                             #
  gem 'database_cleaner', '~> 1.4.1'
  # used by cucumber for db transactions

  gem 'turn', '~>0.8.3', require: false
  # Pretty printed test output.
  # (version constraint is to avoid minitest requirement)
  gem 'minitest'
end

group :development do
  gem 'rails-dev-tweaks'
  gem 'sprockets' # just so above works

  gem 'capistrano', '3.2.1' # note - ssh was breaking on 3.3.3
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  gem 'capistrano-maintenance', require: false
  gem 'rubocop', '0.35.1'
  gem 'rubocop-decko'
end

group :test, :development do
  gem 'thin'
  gem 'pry', git: 'https://github.com/pry/pry'  # bug in 0.10.3, fixed in master
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  if RUBY_VERSION =~ /^2/
    gem 'pry-byebug'
  end
end

Dir.glob('mod/**{,/*/**}/Gemfile').each do |gemfile|
  instance_eval(File.read(gemfile))
end
