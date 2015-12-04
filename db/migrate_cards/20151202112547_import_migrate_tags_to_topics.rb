# -*- encoding : utf-8 -*-

def put_things_in_tag_to_correct_position cards, skip_year
  cards.each do |card|
    puts "migrating #{card.name}'s tags"
    company = card.fetch trait: :wikirate_company, new: {}
    topic = card.fetch trait: :wikirate_topic, new: {}
    year = card.fetch trait: :year, new: {}
    card.fetch(trait: :wikirate_tag).item_cards do |tag|
      case tag.type_id
      when Card::WikirateCompanyID then company << tag
      when Card::WikirateTopicID then topic << tag
      when Card::YearID then year << tag unless skip_year
      end
    end
    company.save!
    topic.save!
    year.save!
  end
end

# migrate tags to topics
# assume some tags are handled manually
class ImportMigrateTagsToTopics < Card::Migration
  def up
    tags_card = Card.search type_id: Card::WikirateTagID
    tags_card.each do |card|
      card.type_id = Card::WikirateTopicID
      puts "Updating #{card.name}'s type to topic"
      card.save!
    end
    note_cards_with_tag = Card.search type_id: Card::ClaimID, right_plus: 'tag'
    put_things_in_tag_to_correct_position note_cards_with_tag, false
    source_cards_with_tag = Card.search type_id: Card::SourceID,
                                        right_plus: 'tag'
    put_things_in_tag_to_correct_position source_cards_with_tag, true
    import_json 'migrate_tags_to_topics.json'
  end
end
