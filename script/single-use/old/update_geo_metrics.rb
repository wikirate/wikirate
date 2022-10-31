# SPDX-FileCopyrightText: 2014 2014 Laureen van Breen, <laureen@wikirate.org> et al.
#
# SPDX-License-Identifier: GPL-3.0-or-later

require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

include Card::Model::SaveHelper

def region_options
  Card.search type: "Region", return: :name, sort_by: :name, limit: 0
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
  metric_name = "Core+#{h[:title]}"
  puts "starting on metric: #{metric_name}"

  ensure_card(h[:title], type: "Metric Title")
  ensure_card metric_name, type_id: Card::MetricID

  f = fields.clone.merge value_options: h[:options]
  f[:formula] = h[:formula] if h[:formula]
  f.each do |fieldcode, content|
    puts "ensuring metric field: #{metric_name}+#{fieldcode}"
    ensure_card [metric_name, fieldcode], content: content
  end
end

puts "starting deep answer update"
Card["Core+#{hq}"].deep_answer_update
