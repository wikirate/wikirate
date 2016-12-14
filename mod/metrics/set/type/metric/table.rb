include_set Abstract::Table
include_set Abstract::SortAndFilter

# tables used on a metric page
format :html do
  def company_table
    items = card.fetch(trait: :all_metric_values).item_cards
    wikirate_table_with_details :company, items,
                                [:company_thumbnail, :value_cell],
                                header: [company_sort_link, value_sort_link],
                                details_view: :company_details_sidebar

  end

  def company_sort_link
    table_sort_link "Companies", :company_name
  end

  def value_sort_link
    table_sort_link "Values", :value
  end
end
