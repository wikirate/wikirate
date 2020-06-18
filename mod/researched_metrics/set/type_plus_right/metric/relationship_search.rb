def virtual?
  true
end

def relationship_relation
  Relationship.where(metric_id: Card.fetch_id(name.left))
end

format :csv do
  view :core do
    Relationship.csv_title +
      card.relationship_relation.map(&:csv_line).join
  end
end