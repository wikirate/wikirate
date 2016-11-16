# -*- encoding : utf-8 -*-

class ImportFixTopicMetricTab < Card::Migration
  def up
    import_cards 'fix_topic_metric_tab.json'
  end
end
