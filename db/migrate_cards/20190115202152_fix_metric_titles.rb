# -*- encoding : utf-8 -*-

class FixMetricTitles < Card::Migration
  def up
    Card.search type_id: Card::MetricID do |metric|
      title = metric.right
      next unless title&.type_code == :basic
      begin
        title.update! type_id: Card::MetricTitleID
      rescue
        puts "failed to update #{title.name}"
      end
    end
  end
end
