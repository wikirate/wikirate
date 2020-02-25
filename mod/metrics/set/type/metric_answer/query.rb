def default_sort_option; end

def inverse_metric_id
  metric_card.inverse_card.id
end

format do
  delegate :inverse_metric_id, to: :card

  def values_query
    inverse? ? inverse_relation_values_query : relation_values_query
  end

  def inverse_relation_values_query
    { left: { left: { left_id: inverse_metric_id },
              right_id: Card.fetch_id(card.year.to_s),
              type_id: MetricAnswerID },
      right_id: card.company_card.id }
  end

  def relation_values_query
    { left_id: card.id, right: { type_id: WikirateCompanyID } }
  end

  def companies
    Card.search values_query
  end

  def inverse_companies
    Card.search inverse_relation_values_query
  end

  def search_with_params
    Card.search values_query.merge(limit: limit, offset: offset)
  end

  def count_with_params
    Card.search values_query.merge(return: :count)
  end

  def limit
    10
  end
end

format :html do
  def limit
    10
  end
end
