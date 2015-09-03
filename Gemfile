source 'http://rubygems.org'

wagn_gem_path = ENV['WIKIRATE_WAGN_GEM_PATH'] || './vendor/wagn'

gem 'wagn', :path=>"#{wagn_gem_path}/wagn"
gem 'card', :path=>"#{wagn_gem_path}/card", :require=>false


gem "mysql2", "~> 0.3"
gem 'link_thumbnailer', "2.5.2"
gem 'open_uri_redirections'
gem 'roo'
gem 'wbench'
gem 'curb'
gem 'delayed_job_active_record'

#if RUBY_PLATFORM !~ /darwin/
group :live do
  gem 'therubyracer'
  gem 'dalli'

end

group :test do
  gem 'rspec-rails', "~> 3.1.0"   # behavior-driven-development suite
  gem 'rspec'
  gem 'rspec-html-matchers', "0.6.1" # 0.7.0 broke stuff!
  #gem 'wagn-rspec-formatter', :git=>'https://github.com/xithan/wagn-rspec-formatter.git'
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
  gem 'database_cleaner', '~> 1.4.1'             # used by cucumber for db transactions

  gem 'turn', "~>0.8.3", :require => false      # Pretty printed test output.  (version constraint is to avoid minitest requirement)
  gem 'minitest'
end

group :development do
  gem 'rails-dev-tweaks'
  gem 'sprockets' # just so above works

  gem 'capistrano', '3.2.1'  #note - ssh was breaking on 3.3.3
  gem 'capistrano-bundler'
  gem 'capistrano-rvm'
end

group :test, :development do

  gem 'thin'
  gem 'pry-rails'
  gem 'pry-rescue'
  gem 'pry-stack_explorer'
  if RUBY_VERSION =~ /^2/
    gem 'pry-byebug'
  end
end

Dir.glob("mod/**{,/*/**}/Gemfile").each do |gemfile|
  instance_eval(File.read(gemfile))
end