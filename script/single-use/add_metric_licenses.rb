require File.expand_path "../../script_helper.rb", __FILE__

Card::MetricQuery.new(
  metric_type: [:researched, :relation, :inverse_relation]
).run.each do |metric|
  metric.license_card.update! content: Card::Set::Right::License::LICENSES.first
end
