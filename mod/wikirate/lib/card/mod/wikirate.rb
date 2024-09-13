Cardio::Railtie.config.tap do |config|
  config.account_password_requirements = %i[special_char number letter]
  config.extra_seed_tables = %w[answers card_counts metrics relationships]
end
