#require File.expand_path "../../../config/environment", __FILE__

# Card::Auth.signin "Ethan McCutchen"

FILENAME = File.expand_path "data/left_right_duplicates.csv"

# include Card::Model::SaveHelper

def raw
  File.read FILENAME
end

puts raw
