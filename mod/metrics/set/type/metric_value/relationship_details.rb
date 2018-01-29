include_set Abstract::Table
include_set Abstract::Paging

def default_sort_option; end

format do
  def values_query
    inverse? ? inverse_relation_values_query : relation_values_query
  end

  def inverse?
    card.metric_card.inverse?
  end

  def inverse_metric_id
    card.metric_card.inverse_card.id
  end

  def inverse_relation_values_query
    {
      left: {
        left: { left_id: inverse_metric_id },
        type_id: MetricValueID
      },
      right_id: card.company_card.id
    }
  end

  def relation_values_query
    { left_id: card.id, right: { type_id: WikirateCompanyID } }
  end

  def count_with_param
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

  def companies
    Card.search values_query
  end

  def inverse_companies
    Card.search inverse_relation_values_query
  end

  def search_with_params
    Card.search values_query.merge(limit: 10, offset: offset)
  end

  def count_with_params
    Card.search values_query.merge(return: :count)
  end

  view :relationship_value_details do
    wrap_value_details do
      [
        "<br/><h5>Relations</h5>",
        render_relations_table_with_details_toggle,
      ]
    end
  end

  view :inverse_relationship_value_details do
    render_relationship_value_details
  end

  view :relations_table_with_details_toggle, cache: :never do
    wrap do
      with_paging view: :relations_table_with_details_toggle do
        relations_table
      end
    end
  end

  def relations_table value_view=:closed_value
    name_view = inverse? ? :inverse_company_name : :company_name
    wikirate_table :company, search_with_params, [name_view, value_view],
                   header: %w[Company Answer]
  end
end
