include_set Abstract::Table

format :html do
  def metric_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table_with_details :metric, items,
                                [:metric_thumbnail_with_vote, :concise],
                                header: ["Metric", "Value"],
                                details_view: :metric_details_sidebar
  end
end
