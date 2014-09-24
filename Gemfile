source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"
gem 'link_thumbnailer', ">= 2.2.3"

#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'
end

group :test do
  gem 'rspec-rails', "~> 2.6"   # behavior-driven-development suite
  gem 'spork', '>=0.9'
  gem 'timecop'
  gem 'simplecov'
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
#  if RUBY_VERSION =~ /^2/
# 		gem 'pry-byebug' 
#  end
end
