# -*- encoding : utf-8 -*-

class ImportCompanyTopicRightSidebarStructure < Card::Migration
  def up
    import_json "company_topic_right_sidebar_structure.json"
  end
end
