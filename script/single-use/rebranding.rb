require File.expand_path "../../../config/environment", __FILE__
require "colorize"

user = Rails.env.development? ? "Joe Admin" : "Ethan McCutchen"
Card::Auth.signin user

names = {
          "WikiRating" => "Rating",
          "WikiRate" => "Wikirate"
        }

def rename card, old_name, new_name
  new_cardname = card.name.gsub old_name, new_name
  puts "renaming #{card.name} to #{new_cardname}"
  card.update! name: new_cardname
rescue StandardError => e
  puts "renaming failed in #{card.name}: #{e.message}".red
end

def rename_in_content card, old_name, new_name
  puts "renaming #{old_name} to #{new_name} in content of #{card.name}"
  card.update! content: card.content.gsub(old_name, new_name)
rescue StandardError => e
  puts "renaming failed in #{card.name}: #{e.message}".red
end

def cards_matching term, field, &block
  Card.where("regexp_like(#{field}, '#{term}', 'c')").find_each &block
end

names.each do |old_name, new_name|
  cards_matching old_name, :name do |card|
    card.include_set_modules
    rename card, old_name, new_name
  end

  cards_matching old_name, :db_content do |card|
    card.include_set_modules
    rename_in_content card, old_name, new_name
  end
end


