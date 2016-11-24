include_set Abstract::Table

# tables used on a metric page
format :html do
  def company_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table_with_details :metric, ["Company", "Value"], items,
                                [:viggles, :concise],
                                details_view: :company_details_sidebar

  end
end
