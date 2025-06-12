require File.expand_path "../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

Cardio.config.perform_deliveries = false
