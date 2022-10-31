# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

LEFTS = File.expand_path "data/bad_lefts.csv"
RIGHTS = File.expand_path "data/bad_rights.csv"

def csv filename
  CSV.new raw(filename), headers: true
end

def raw filename
  File.read filename
end

def fetch id
  Card.fetch id.to_i, look_in_trash: true
end

def delete_descendants c
  c.each_descendant { |d| delete d }
end

def delete c
  puts "deleting #{c.name}"
  c.update_column :trash, true
end

[LEFTS, RIGHTS].each do |filename|
  csv(filename).each do |r|
    unless (c = fetch r["id"])
      puts "skipping #{r['name']}"
      next
    end

    delete_descendants c
    delete c
  end
end

puts "done."
