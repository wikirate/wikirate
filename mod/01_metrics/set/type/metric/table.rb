include_set Abstract::Table

# tables used on a metric page
format :html do
  def company_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table_with_details :company, ["Company", "Value"], items,
                                [:company_thumbnail, :concise],
                                details_append: :company_details_sidebar

  end
end
