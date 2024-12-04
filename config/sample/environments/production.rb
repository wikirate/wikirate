# -*- encoding : utf-8 -*-

Decko::Deck.configure do
  # Settings specified here will take precedence over those in
  # config/application.rb

  config.view_cache = true
  config.action_mailer.perform_deliveries = false
  # config.cache_store = :mem_cache_store, []
end
