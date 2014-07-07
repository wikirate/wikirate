source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"
gem 'link_thumbnailer'

#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'
end

group :test do
  gem 'rspec-rails', "~> 2.6"   # behavior-driven-development suite
  gem 'spork', '>=0.9'
  gem 'timecop'
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end

group :test, :development do
  gem "byebug"
end
