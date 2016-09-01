# -*- encoding : utf-8 -*-

class ImportUpdateTopicTabs < Card::Migration
  def up
    import_cards 'update_topic_tabs.json'
  end
end
