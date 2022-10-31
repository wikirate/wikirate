# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later


require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

require "csv"

FILENAME = File.expand_path "script/single-use/data/wrong_year2.csv"

# For correcting answer years
module AnswerFixer
  class << self
    def csv
      CSV.new raw, headers: true
    end

    def raw
      File.read FILENAME
    end

    def card_ok id
      card = Card[id.to_i]
      return card if card

      puts "could not find card with id #{id}"
      false
    end

    def year_ok year, card
      return year unless year == card.year

      puts "year is already correct: #{card.name}"
      false
    end

    def name_ok year, card
      new_name = Card::Name[card.name.left, year]
      return new_name unless Card[new_name]

      puts "card already exists: #{new_name}"
      false
    end

    def run!
      csv.each do |r|
        next unless
          (card = card_ok r["Answer ID"]) &&
          (year = year_ok r["Correct year"], card) &&
          (name = name_ok year, card)
        puts "renaming: #{card.name}\n      to: #{name}"
        card.update! name: name
      end
    end
  end
end

AnswerFixer.run!
puts "done."
