# -*- encoding : utf-8 -*-

class ImportBrowseCompanyTopicMetricStructures < Card::Migration
  def up
    import_cards 'browse_company_topic_metric_structures.json'
  end
end
