# -*- encoding : utf-8 -*-

class ImportUpdateTopicStructure < Card::Migration
  def up
    import_cards 'update_topic_structure.json'
  end
end
