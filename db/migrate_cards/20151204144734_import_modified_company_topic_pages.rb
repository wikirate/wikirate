# -*- encoding : utf-8 -*-

class ImportModifiedCompanyTopicPages < Card::Migration
  def up
    import_json 'modified_company_topic_pages.json'
  end
end
