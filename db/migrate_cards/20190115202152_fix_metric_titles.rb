# -*- encoding : utf-8 -*-

class FixMetricTitles < Card::Migration
  def up
    Card.search type_id: Card::MetricID do |metric|
      next if metric.score?
      title = metric.right
      next if title.type_code.in? %i[metric_title report_type]
      begin
        title.update! type_id: Card::MetricTitleID
      rescue
        puts "failed to update #{title.name}"
      end
    end
  end
end
