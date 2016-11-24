include_set Abstract::Table

# tables used on a metric page
format :html do
  def company_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table :metric, ["Company", "Value"], items,
                   [:company_thumbnail, :concise, :details_placeholder],
                   details_append: append_name,
                   td: {
                       classes: ["header", "data", "details"]
                   }
  end

  def append_name
    if card.metric_type_codename == :score
      "score_metric_details_company_header"
    else
      "metric_details_company_header"
    end
  end
end
