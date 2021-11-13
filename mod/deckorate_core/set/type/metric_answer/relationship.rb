event :update_relationship_count, :after_integrate,
      on: :save, when: :update_relationship_count? do
  count = relationship_answer_count
  if count.positive?
    update_relationship_answer_count! count
  elsif !trash
    director.restart
    delete
  end
end

def update_relationship_count?
  return unless metric_card.relationship?
  new? || @update_relationship_count
end

def update_relationship_answer_count! count=nil
  count ||= relationship_answer_count
  value_card.director.restart
  value_card.update content: count
end

def schedule_answer_count
  @update_relationship_count = true
end

# number of companies that have a relationship answer for this answer
def relationship_answer_count
  id ? ::Relationship.where(metric_card.answer_lookup_field => id).count : 0
end
