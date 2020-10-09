ENV["RAILS_ENV"] = "staging"

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"



puts "cards: #{Card.count}"