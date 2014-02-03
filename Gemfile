source 'http://rubygems.org'

gem 'wagn', :path=>'/opt/wagn'
gem "mysql2", "~> 0.3"

gem 'dalli'


# These should only be needed if you're developing new JS / CSS.  It's all pre-compiled for production
group :assets do
  gem 'sass-rails',   "~> 3.1"                 # pretty code; compiles to CSS
  gem 'coffee-rails', "~> 3.1"                 # pretty code; compiles to JS
  gem 'uglifier'                               # makes pretty code ugly again.  compresses js/css for fast loading

  gem 'jquery-rails',  '~> 2.1.4'              # main js framework, along with rails-specific unobtrusive lib
  gem "jquerymobile-rails", "~> 0.2"
  
  gem 'tinymce-rails', '~> 3.4'                # wysiwyg editor
  
  # execjs is necessary for developing coffeescript.  mac users have execjs built-in; don't need this one
  gem 'therubyrhino', :platform=>:ruby         # :ruby is MRI rubies, so if you use a mac ruby ...
end

group :development do
  gem 'capistrano'
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
  
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  gem 'rails-dev-tweaks', '~> 0.6'             # dramatic speeds up asset loading, among other tweaks
end