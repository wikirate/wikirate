source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"
gem "byebug"
#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'
end
gem 'rspec-rails', "~> 2.6"   # behavior-driven-development suite
gem 'spork', '>=0.9'
gem 'timecop'
group :development do
  gem 'wagn-dev' #, :path=>'/opt/wagn-dev'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end
