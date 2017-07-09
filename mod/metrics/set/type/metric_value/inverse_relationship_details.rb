include_set Abstract::Table

format :html do
  def inverse_metric_id
    card.metric_card.inverse_card.id
  end

  def inverse_values
    Card.search left: {
      left: { left_id: inverse_metric_id },
      type_id: MetricValueID
    },
                right_id: card.company_card.id
  end

  view :inverse_relationship_value_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_value_details do
      [
        wrap_with(:div, checked_by, class: "double-check"),
        "<h5>Relations</h5>",
        inverse_relations_table
      ]
    end
  end

  def inverse_relations_table
    wikirate_table :company, inverse_values, [:inverse_company_name, :value],
                   header: %w[Company Answer]
  end
end
