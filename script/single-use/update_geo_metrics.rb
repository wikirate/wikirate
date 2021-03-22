require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Joe Admin"
# Card::Auth.signin "Ethan McCutchen"

include Card::Model::SaveHelper

["Country", "Headquarters Location", "ILO Region"].each do |title|
  ensure_card(title, type: "Metric Title")
  metric_name = "Core+#{title}"
  ensure_card metric_name, type_id: Card::MetricID
  ensure_card [metric_name, :metric_type], content: "Formula"
  ensure_card [metric_name, :value_type], content: "Free Text"
end
