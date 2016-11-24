include_set Abstract::Table

format :html do
  def metric_table
    items = card.fetch(trait: :all_metrics).item_cards
    wikirate_table_with_details :metric, nil, items,
                                [:thumbnail_wth_vote, :company_count_with_label],
                                details_append: "topic_page_metric_details"
  end

  def company_table
    items = card.fetch(trait: :all_companies).item_cards
    wikirate_table_with_details :company, nil, items,
                                [:thumbnail, :review_count_with_label,
                                 :metric_count_with_label, :note_count_with_label,
                                 :source_count_with_label],
                                details_append: "topic_page_company_details"
  end
end
