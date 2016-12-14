include_set Abstract::Table
include_set Abstract::SortAndFilter

def default_sort_option
  :importance
end

format :html do
  def metric_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table_with_details :metric, items,
                                [:metric_thumbnail_with_vote, :value_cell],
                                header: [name_sort_links, "Value"],
                                details_view: :metric_details_sidebar
  end

  def name_sort_links
    "#{importance_sort_link}#{designer_sort_link}#{title_sort_link}"
  end

  def title_sort_link
    table_sort_link "Metrics", :title_name, "pull-left margin-left-20"
  end

  def designer_sort_link
    table_sort_link "", :designer_name, "pull-left margin-left-20"
  end

  def importance_sort_link
    table_sort_link "", :importance, "pull-left  margin-left-15"
  end

end
