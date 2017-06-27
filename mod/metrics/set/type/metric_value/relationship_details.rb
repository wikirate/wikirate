include_set Abstract::Table

format :html do

  def companies
    Card.search left_id: card.id, right: { type_id: WikirateCompanyID }
  end

  view :relationship_value_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_value_details do
      [
        wrap_with(:div, checked_by, class: "double-check"),
        "<h5>Relations</h5>",
        relations_table_with_details_toggle,
        # wrap_with(:div, _render_sources, class: "cited-sources")
      ]
    end
  end

  def relations_table_with_details_toggle
    wikirate_table :company, companies, [:company_name, :closed_value],
                       header: %w[Company Answer]
  end

  def relations_table
    wikirate_table :company, companies, [:company_name, :value],
                   header: %w[Company Answer]
  end

end
