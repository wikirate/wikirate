source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"

if RUBY_PLATFORM !~ /darwin/
  gem 'therubyracer'
  gem 'dalli'
end

group :development do
  gem 'wagn-dev', :path=>'/opt/wagn-dev'
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end
