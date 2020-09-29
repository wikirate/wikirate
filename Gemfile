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


# DATABASE
gem "mysql2", "> 0.4"


# ALL-ENVIRONMENT MODS
gem "card-mod-bookmarks", path: "./vendor/card-mods"
gem "card-mod-csv_import"
gem "card-mod-new_relic"

# gem "card-mod-logger"
gem "card-mod-pdfjs", path: "./vendor/card-mods/pdfjs"
gem "card-mod-solid_cache", path: "./vendor/card-mods/solid_cache"


# SOURCE HANDLING
gem "link_thumbnailer"               # parses some sources
gem "open_uri_redirections"          # redirections from http to https or vice versa
gem "roo"                            # Spreadsheet-related tasks
gem "pdfkit"                         # PDF-related tasks
gem "wkhtmltopdf-binary", "0.12.5.4" # converting HTML to PDF

# MATH
gem "descriptive_statistics" # adds stats methods to enumerables
gem "savanna-outliers"       # calculates outliers
gem "statistics2"            # required by savanna-outliers

# MISCELLANEOUS
gem "company-mapping" # Vasso's gem, written for WikiRate
gem "fog-aws"
gem "rack-cors"
gem "bulk_insert"



gem "bcrypt_pbkdf"
gem "ed25519"
gem "sprockets"
gem "airbrussh", require: false
gem "ruby-jmeter"

# BACKGROUNDING
gem "curb"
gem "daemons"
gem "delayed_job_active_record"
gem "delayed_job_web"

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
  gem "rubocop-ast", "~> 0.5.0" # version jump to 0.7 produced lots of errors
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

group :profile do
  gem "decko-profile"
  gem "wbench" # Benchmarking web requests
end

Dir.glob("mod/**/Gemfile").each { |gemfile| instance_eval(File.read(gemfile)) }