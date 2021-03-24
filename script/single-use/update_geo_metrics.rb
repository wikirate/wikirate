require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

include Card::Model::SaveHelper

def region_options
  Card.search type: "Region", return: :name, sort: :name, limit: 0
end

def country_options
  Card.search(
    left: { type: "Region" },
    right: "Country",
    limit: 0
  ).map(&:content).uniq.sort.compact
end

def ilo_options
  ["Africa", "Americas", "Arab States", "Asia and the Pacific", "Europe and Central Asia"]
end

hq = "Headquarters Location"

metrics = [
  { title: hq, options: region_options },
  { title: "Country", options: country_options, formula: "Country[{{Core+#{hq}}}]" },
  { title: "ILO Region", options: ilo_options, formula: "ILORegion[{{Core+#{hq}}}]" }
]

fields = {
  metric_type: "Formula",
  value_type: "Category"
}

metrics.each do |h|
  ensure_card(h[:title], type: "Metric Title")

  metric_name = "Core+#{h[:title]}"
  metric_card = ensure_card metric_name, type_id: Card::MetricID
  metric_card.answers.each do |answer|
    answer.delete!
  end

  f = fields.clone.merge value_options: h[:options]
  f[:formula] = h[:formula] if h[:formula]
  f.each do |fieldcode, content|
    ensure_card [metric_name, fieldcode], content: content
  end
end

Card["Core+#{hq}"].deep_answer_update
