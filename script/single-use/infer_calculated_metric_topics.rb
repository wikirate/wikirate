require File.expand_path "../../script_helper.rb", __FILE__

Card.where(type_id: Card::MetricID).find_each do |metric|
  metric.include_set_modules
  next unless metric.researched?

  metric.topic_card.cascade_topics
rescue
  puts "failed to update #{metric.name}".red
end
