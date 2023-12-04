Cardio::Railtie.config.tap do |config|
  config.account_password_requirements = %i[special_char number letter]
end
