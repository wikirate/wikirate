# for use in the console

metric_type_ids = [Card::RelationID, Card::InverseRelationID]
Metric.where("metric_type_id in (#{metric_type_ids.join ', '})").each do |m|
  ::Answer.where(metric_id: m.metric_id).each do |a|
    cnt = a.relationship_count
    next if a.value.to_i == cnt
    puts "update #{a.name} from #{a.value} to #{cnt}"
    a.value_card.update! content: cnt
  end
end; ""
# this little semicolon/quotation trick is just to prevent noise in the console
