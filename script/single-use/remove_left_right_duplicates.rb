require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"
require "csv"

FILENAME = File.expand_path "data/left_right_duplicates.csv"

# include Card::Model::SaveHelper

def csv
  CSV.new raw, headers: :true
end

def raw
  File.read FILENAME
end

def fetch id
  Card.fetch id.to_i, look_in_trash: true
end

def trash_test card
  puts "#{card.name} is in trash" if card.trash

end

csv.each do |r|
  c1 = fetch r["id1"]
  c2 = fetch r["id2"]

  trash_test c1
  trash_test c2
end


puts "done."