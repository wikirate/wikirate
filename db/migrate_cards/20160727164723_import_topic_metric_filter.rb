# -*- encoding : utf-8 -*-

class ImportTopicMetricFilter < Card::Migration
  def up
    import_cards 'topic_metric_filter.json'
  end
end
