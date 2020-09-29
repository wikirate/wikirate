# -*- encoding : utf-8 -*-
source "http://rubygems.org"

if ENV["RM_INFO"] && ARGV[0] == 'check'
  puts "Execution in RubyMine detected in Gemfile. Ignoring decko gem path"
  # This causes Rubymine and IntelliJ to handle these paths as normal sources rather
  # than gems or libraries.
  # That way the files are included as normal project sources in Find and Open.
else
  gem "decko", path: "./vendor/decko"
  gem "card-mod-defaults"
end

gem "card-mod-bookmarks", path: "./vendor/card-mods/bookmarks"
gem "card-mod-csv_import", path: "./vendor/card-mods/csv_import"
# gem "card-mod-logger", path: "./vendor/card-mods/logger"
gem "card-mod-new_relic", path: "./vendor/card-mods/new_relic"
gem "card-mod-pdfjs", path: "./vendor/card-mods/pdfjs"
gem "card-mod-solid_cache", path: "./vendor/card-mods/solid_cache"

gem "mysql2", "> 0.4"

gem "bulk_insert"
gem "descriptive_statistics"
gem "savanna-outliers"
gem "statistics2"

gem "curb"
gem "daemons"
gem "delayed_job_active_record"
gem "delayed_job_web"

gem "company-mapping"
gem "link_thumbnailer"
gem "nokogumbo"
gem "open_uri_redirections"
gem "pdfkit"
gem "roo"
gem "wbench"
gem "wkhtmltopdf-binary", "0.12.5.4"



gem "fog-aws"
gem "rack-cors"

gem "bcrypt_pbkdf"
gem "ed25519"

gem "sprockets"

# seems like newrelic should be in :live, but that wasn't working.
# not sure why -efm
gem "newrelic_rpm"
# gem "ruby-prof"
gem "airbrussh", require: false

gem "ruby-jmeter"

group :live do
  gem "dalli"
  gem "therubyracer"
end

group :test do
  gem "decko-rspec"
  gem "decko-cucumber"

  gem "timecop"
end

group :development do
  gem "card-mod-monkey"

  gem "rubocop", "0.88" # 0.89 introduced bugs. may get resolved in rubocop-decko update?
  gem "rubocop-ast", "~>0.5.0"
  gem "rubocop-decko"

  gem "capistrano"
  gem "capistrano-bundler"
  gem "capistrano-git-with-submodules", '~> 2.0'
  gem "capistrano-maintenance", require: false
  gem "capistrano-passenger"
  gem "capistrano-rvm"
  gem "pivotal-tracker"
end

group :test, :development, :cypress do
  gem "decko-spring"
  gem "decko-cypress"
  gem "puma"
end

Dir.glob("mod/**/Gemfile").each do |gemfile| instance_eval(File.read(gemfile)) end