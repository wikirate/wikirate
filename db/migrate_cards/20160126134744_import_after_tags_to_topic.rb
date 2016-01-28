# -*- encoding : utf-8 -*-

class ImportAfterTagsToTopic < Card::Migration
  def up
    import_json 'after_tags_to_topic.json'
  end
end
