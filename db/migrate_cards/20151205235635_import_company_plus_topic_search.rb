# -*- encoding : utf-8 -*-

class ImportCompanyPlusTopicSearch < Card::Migration
  def up
    import_json "company_plus_topic_search.json"
    
  end
end
