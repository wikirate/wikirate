# -*- encoding : utf-8 -*-

class ImportTopicPageFilter < Card::Migration
  def up
    import_cards "topic_page_filter.json"
  end
end
