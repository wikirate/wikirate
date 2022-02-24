event :update_relationship_count, delay: true, priority: 4 do
  count = relationship_answer_count
  if count.positive?
    update_relationship_answer_count! count
  else
    director.restart
    delete
  end
end

def update_relationship_answer_count! count=nil
  count ||= relationship_answer_count
  value_card.update! content: count
end

# number of companies that have a relationship answer for this answer
def relationship_answer_count
  id ? ::Relationship.where(metric_card.answer_lookup_field => id).count : 0
end
