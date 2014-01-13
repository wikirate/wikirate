source 'http://rubygems.org'

gem 'wagn', '~>1.12.5', :path=>File.expand_path( '../../gem', __FILE__ )


group :mysql do
  gem "mysql2", "~> 0.3"
end

group :postgres do
  gem 'pg', '~>0.12.2'
  # if using 1.8.7 or ree and having no luck with the above, try:
  # gem 'postgres', '~>0.7.9.2008.01.28'
end
#gem 'sqlite3-ruby', :require => 'sqlite3', :group=>'sqlite'

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

group :test, :development do
  gem 'rspec-rails', "~> 2.6"                  # behavior-driven-development suite
  gem 'rails-dev-tweaks', '~> 0.6'             # dramatic speeds up asset loading, among other tweaks


#  gem "jeweler", "~> 1.8.8"

#  gem 'jasmine-rails'
end