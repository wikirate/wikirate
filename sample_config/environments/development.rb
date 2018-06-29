# -*- encoding : utf-8 -*-


BetterErrors.editor='x-mine://open?file=%{file}&line=%{line}' if defined? BetterErrors

Wikirate::Application.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb

  config.action_mailer.perform_deliveries = false
  config.performance_logger = {
    methods: [:view, :event, :fetch, :sql],
    max_depth: 15,
    min_time: 10
  }
  # config.log_level = :wagn
  config.log_level = :debug
  # config.view_cache = true
end

