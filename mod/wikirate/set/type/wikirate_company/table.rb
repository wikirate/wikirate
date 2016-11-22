include_set Abstract::Table

format :html do
  def metric_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table :metric, ["Metric", "Value"], items,
                   [:thumbnail_with_vote, :concise, :details_placeholder],
                   details_append: "metric_details_metric_header",
                   td: {
                       classes: ["header", "data", "details"]
                   }
  end
end
