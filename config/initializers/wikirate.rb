# These are for settings that we ALWAYS want Wikirate to use.

# The advantage of doing them here is that we don't have to copy them to config
# files on other servers. The disadvantage is that we can't override them elsewhere
# or in different environments.
Cardio::Railtie.config.tap do |config|
  config.account_password_requirements = %i[special_char number letter]

  config.seed_mods.unshift :wikirate
  config.extra_seed_tables = %w[answers card_counts metrics relationships]

  config.allow_anonymous_cookies = false
end

Decko::Deck.configure do
  # (needed so setup finds wr schema)
  config.paths.add "db", with: "db"
end
