source 'http://rubygems.org'

gem 'wagn', :path=>'./vendor/wagn'
gem "mysql2", "~> 0.3"
gem 'link_thumbnailer', ">= 2.2.3"


#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'
end

group :test do
  gem 'rspec-rails', "~> 3.1.0"   # behavior-driven-development suite
  gem 'rspec'
  gem 'rspec-html-matchers'
#  gem 'wagn-rspec-formatter', :path=>'/opt/wagn-rspec-formatter'
  gem 'spork', '>=0.9'
  gem 'timecop'
  gem 'simplecov'

  # CUKES see features dir
  gem 'cucumber-rails', :require=>false #, '~> 1.3', :require=>false # feature-driven-development suite
  gem 'capybara'#, '~> 2.2.1'                     # note, selectors were breaking when we used 2.0.1
  gem 'selenium-webdriver'#, '~> 2.39'
#  gem 'capybara-webkit'
  gem 'launchy'                                # lets cucumber launch browser windows

  # NOTE: had weird errors with timecop 0.4.4.  would like to update when possible


  gem 'email_spec'                             #
  gem 'database_cleaner', '~> 0.7'             # used by cucumber for db transactions

  gem 'turn', "~>0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  gem 'minitest', "~>4.0"
end

group :development do
  gem 'rails-dev-tweaks'
  gem 'sprockets' # just so above works
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'

end

group :test, :development do
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  # if RUBY_VERSION =~ /^2/
  #   gem 'pry-byebug'
  # end
end
