# -*- encoding : utf-8 -*-

class ImportTopicTags < Card::Migration
  def up
    import_cards 'topic_tags.json'
  end
end
