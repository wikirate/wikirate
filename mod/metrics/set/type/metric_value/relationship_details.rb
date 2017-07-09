include_set Abstract::Table
include_set Abstract::Paging

def default_sort_option
end

format do
  def count_with_params
    Card.search left_id: card.id, right: { type_id: WikirateCompanyID },
                return: :count
  end

end

format :html do
  def limit
    10
  end

  def companies
    Card.search left_id: card.id, right: { type_id: WikirateCompanyID }
  end

  def search_with_params
    Card.search left_id: card.id, right: { type_id: WikirateCompanyID },
                limit: 10, offset: offset
  end

  def count_with_params
    Card.search left_id: card.id, right: { type_id: WikirateCompanyID },
                return: :count
  end

  view :relationship_value_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_value_details do
      [
        wrap_with(:div, checked_by, class: "double-check"),
        "<h5>Relations</h5>",
        render_relations_table_with_details_toggle,
        # wrap_with(:div, _render_sources, class: "cited-sources")
      ]
    end
  end

  view :relations_table_with_details_toggle do
    wrap do
      with_paging view: :relations_table_with_details_toggle do
        wikirate_table :company, search_with_params, [:company_name, :closed_value],
                       header: %w[Company Answer]
      end
    end
  end

  def relations_table
    wikirate_table :company, companies, [:company_name, :value],
                   header: %w[Company Answer]
  end
end
