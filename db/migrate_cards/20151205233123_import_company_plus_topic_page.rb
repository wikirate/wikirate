# -*- encoding : utf-8 -*-

class ImportCompanyPlusTopicPage < Card::Migration
  def up
    import_json "company_plus_topic_page.json"
    
  end
end
