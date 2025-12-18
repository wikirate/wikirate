source "http://rubygems.org"

if ENV["RM_INFO"] && ARGV[0] == "check"
  puts "Execution in RubyMine detected in Gemfile. Ignoring decko gem path"
  # This causes Rubymine and IntelliJ to handle these paths as normal sources rather
  # than gems or libraries.
  # That way the files are included as normal project sources in Find and Open.
else
  path "./vendor/decko" do
    gem "card", require: false
    gem "cardname"
    gem "decko"
  end

  path "./vendor/decko/mod" do
    gem "card-mod-defaults"
    gem "card-mod-delayed_job"
  end

  path "./vendor/card-mods" do
    gem "card-mod-alias"
    gem "card-mod-bookmarks"
    gem "card-mod-counts"
    gem "card-mod-csv_import"
    gem "card-mod-filter"
    gem "card-mod-flag"
    gem "card-mod-fulltext"
    gem "card-mod-google_analytics"
    gem "card-mod-graphql"
    gem "card-mod-lookup"
    gem "card-mod-social"
    # gem "card-mod-logger"
    gem "card-mod-new_relic"
    gem "card-mod-pdfjs"
    gem "card-mod-solid_cache"
    gem "card-mod-thumbnail"
  end

  path "./vendor/decko/support" do
    gem "decko-cucumber", group: :cucumber
    gem "decko-cypress", group: :cypress
    gem "decko-rspec", group: :test
  end

  path "./mod" do
    gem "card-mod-deckorate_search"
  end
  # gem "card-mod-wikirate_shared", path: "./vendor/wikirateproject/mod/wikirate_shared"
end

# DATABASE
gem "mysql2", "> 0.4"

# DATABASE OPTIMIZATION
gem "pluck_all"                      # supports optimized pluck queries

# FILE / SOURCE HANDLING
gem "addressable"                    # URI encoding
gem "curb"                           # libcurl bindings for ruby
gem "fog-aws"                        # supports AWS file storage
gem "link_thumbnailer"               # parses some sources
gem "open_uri_redirections"          # redirections from http to https or vice versa
gem "roo"                            # Spreadsheet-related tasks

gem "pdfkit"                         # PDF-related tasks
gem "wkhtmltopdf-binary"             # converting HTML to PDF

# MATH
# gem "descriptive_statistics"         # adds stats methods to enumerables
# gem "savanna-outliers"               # calculates outliers
# gem "statistics2"                    # required by savanna-outliers

# MISCELLANEOUS
gem "company-mapping"                # Vasso's gem, written for WikiRate
gem "puma", "~>5.6"                  # local webserver (6.x broke semaphore )
gem "rack-attack"                    # protection from bad clients
gem "rack-cors"                      # support for Cross-Origin Resource Sharing (CORS)

# VERSIONING ISSUES
gem "ffi", "1.16.3"                  # 1.17 requires rubygems version >= 3.3.22
gem "net-imap", "0.4.17"             # 0.5.0 requires ruby version >= 3.1.0

group :live do
  gem "dalli"                        # Memcache
  gem "connection_pool", "~> 2.4"    # 3.x releases broke memcache handling
  # gem "therubyracer"                 # JS runtime
end

group :development do
  gem "card-mod-monkey", path: "./vendor/decko/mod"

  # gem "rubocop-ast"
  # gem "rubocop-decko"

  gem "pivotal-tracker"
end

gem "timecop", group: %i[test cucumber] # date/time manipulation in tests

group :test, :development do
  # gem "debase"
  gem "decko-spring", path: "./vendor/decko/support"
  # gem "ruby-debug-ide"
end

group :profile do
  gem "decko-profile", path: "./vendor/decko/support"
  gem "ruby-jmeter"                  # connected to Flood.io, used in load testing
  gem "wbench"                       # Benchmarking web requests
end
