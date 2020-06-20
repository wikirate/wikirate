def virtual?
  true
end

def relationships
  Card.fetch(name.left).relationships
end

format :csv do
  view :core do
    ::Relationship.csv_title +
      card.relationships.map(&:csv_line).join
  end
end
