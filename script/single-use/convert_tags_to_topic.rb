require File.expand_path("../../config/environment",  __FILE__)
require "colorize"

def put_things_in_tag_to_correct_position cards, skip_year
  i = 0
  cards.each do |card|
    puts "migrating #{card.name}'s tags".green
    company, topic, year = get_subcards card
    fill_subcards card, company, topic, year, skip_year
    updated_cards [company, topic, year]
    i += 1
    Card.cache.reset if i % 10 == 0
  end
end

def fill_subcards card, company, topic, year, skip_year
  card.fetch(trait: :wikirate_tag).item_cards.each do |tag|
    case tag.type_id
    when Card::WikirateCompanyID then company << tag
    when Card::WikirateTopicID then topic << tag
    when Card::YearID then year << tag unless skip_year
    end
  end
end

def get_subcards card
  company = card.fetch trait: :wikirate_company, new: {}
  topic = card.fetch trait: :wikirate_topic, new: {}
  year = card.fetch trait: :year, new: {}
  [company, topic, year]
end

def updated_cards cards
  cards.each do |card|
    update_card card
  end
end

def update_card card
  return unless card.changed? && !card.item_names.empty?
  puts "\tUpdating #{card.name} to #{card.content}".green
  card.save!
end

Card::Auth.as_bot do
  Card::Mailer.perform_deliveries = false
  puts "Searching tag cards".green
  tags_card = Card.search type_id: Card::WikirateTagID, sort: :name
  puts "#{tags_card.size} tag cards found.".green
  tags_card.each do |card|
    card.type_id = Card::WikirateTopicID
    puts "Updating #{card.name}'s type to topic".green
    card.save!
    Card.cache.reset
  end
  puts "Finished type updates!".green
  puts "Getting all source + tag cards".green
  source_cards_with_tag = Card.search type_id: Card::SourceID,
                                      right_plus: "tag"
  puts "#{source_cards_with_tag.size} note+tag cards found. Start Praying".green
  put_things_in_tag_to_correct_position source_cards_with_tag, true
  puts "Finished source+tag updates!".green
  Card::Mailer.perform_deliveries = true
end
