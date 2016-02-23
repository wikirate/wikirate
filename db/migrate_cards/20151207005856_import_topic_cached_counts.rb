# -*- encoding : utf-8 -*-

class ImportTopicCachedCounts < Card::Migration
  def up
    import_json "topic_cached_counts.json"
    
  end
end
