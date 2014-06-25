source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"

#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end
