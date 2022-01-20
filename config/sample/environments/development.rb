# -*- encoding : utf-8 -*-

Wikirate::Application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb

  if ENV["WIKIRATE_IDE"] == "RubyMine"
    BetterErrors.editor = "x-mine://open?file=%{file}&line=%{line}"
  end

  # config.performance_logger = {
  #     :min_time => 0,            # show only method calls that are slower than 100ms
  #     :max_depth => 3,           # show nested method calls only up to depth 3
  #     :details=> true,           # show method arguments and sql
  #     :methods => [:view, :search, :execute],  # choose methods to log
  #     :log_level => :info
  # }
end
