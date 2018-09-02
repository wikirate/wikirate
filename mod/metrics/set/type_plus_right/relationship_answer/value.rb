include_set Abstract::MetricChild, generation: 4

def relationship_count_value?
  metric_card.relationship? && left.type_id == Card::MetricAnswerID
end

format :html do
  def edit_fields
    [
      value_field_card_and_options,
      check_request_field_card_and_options
    ]
  end

  def check_request_base
    card.left(new: { type_id: RelationshipAnswerID })
  end
end
