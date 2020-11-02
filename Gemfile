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
  gem "card-mod-delayed_job"

  gem "card-mod-bookmarks", path: "./vendor/card-mods"
  gem "card-mod-counts"
  gem "card-mod-csv_import"
  gem "card-mod-fulltext"
  # gem "card-mod-logger"
  gem "card-mod-new_relic"
  gem "card-mod-pdfjs"
  gem "card-mod-solid_cache"

  gem "decko-cucumber", group: :cucumber
  gem "decko-rspec", group: :test

  gem "decko-cap", path: "./vendor/decko-cap", group: :development
end

# DATABASE
gem "mysql2", "> 0.4"

# FILE / SOURCE HANDLING
gem "addressable"                    # URI encoding
gem "curb"                           # libcurl bindings for ruby
gem "fog-aws"                        # supports AWS file storage
gem "link_thumbnailer"               # parses some sources
gem "open_uri_redirections"          # redirections from http to https or vice versa
gem "roo"                            # Spreadsheet-related tasks

gem "pdfkit"                         # PDF-related tasks
gem "wkhtmltopdf-binary", "0.12.5.4" # converting HTML to PDF

# MATH
gem "descriptive_statistics"         # adds stats methods to enumerables
gem "savanna-outliers"               # calculates outliers
gem "statistics2"                    # required by savanna-outliers

# MISCELLANEOUS
gem "bulk_insert"                    # adds #bulk_insert method used for answer
gem "company-mapping"                # Vasso's gem, written for WikiRate
gem "rack-cors"                      # support for Cross-Origin Resource Sharing (CORS)

group :live do
  gem "dalli"                        # Memcache
  gem "therubyracer"                 # JS runtime
end

group :development do
  gem "card-mod-monkey"

  gem "rubocop-ast", "~> 0.5.0" # version jump to 0.7 produced lots of errors
  gem "rubocop-decko"

  gem "pivotal-tracker"
end

gem "timecop", group: %i[test cucumber] # date/time manipulation in tests

group :test, :development, :cypress do
  gem "decko-cypress"
  gem "decko-spring"
  gem "puma"                         # local webserver
end

group :profile do
  gem "decko-profile"
  gem "ruby-jmeter"                  # connected to Flood.io, used in load testing
  gem "wbench"                       # Benchmarking web requests
end

Dir.glob("mod/**/Gemfile").each { |gemfile| instance_eval(File.read(gemfile)) }
