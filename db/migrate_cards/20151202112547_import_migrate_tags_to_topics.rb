# -*- encoding : utf-8 -*-

# migrate tags to topics
class ImportMigrateTagsToTopics < Card::Migration
  def up
    tags_card = Card.search type_id: Card::WikirateTagID
    tags_card.each do |card|
      card.type_id = Card::WikirateTopicID
      puts "Updating #{card.name}'s type to topic"
      card.save!
    end
    import_json 'migrate_tags_to_topics.json'
  end
end
