# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"
require "csv"

FILENAME = File.expand_path "data/left_right_duplicates.csv"

# include Card::Model::SaveHelper

def csv
  CSV.new raw, headers: true
end

def raw
  File.read FILENAME
end

def fetch id
  Card.fetch id.to_i
end

csv.each do |r|
  next unless (c1 = fetch r["id1"]) && (fetch r["id2"]) # skip if one is in trash
  puts "trashing #{c1.name}"
  c1.update_column :trash, true
end

puts "done."
