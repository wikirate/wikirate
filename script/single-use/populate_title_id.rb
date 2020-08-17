require File.expand_path "../../../config/environment", __FILE__

Card::Auth.signin "Ethan McCutchen"

Card.search(type: :metric, limit: 0).each do |metric|
  puts "updating #{metric.name}"
  Answer.where(metric_id: metric.id).update_all title_id: metric.metric_title_id
end

puts "done."
