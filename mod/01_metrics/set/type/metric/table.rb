include_set Abstract::Table

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
    sort_link "Companies #{sort_icon :name}",
              sort_by: 'name', sort_order: toggle_sort_order(:name),
              class: 'header'
  end

  def value_sort_link
    sort_link "Values #{sort_icon :value}",
              sort_by: 'value', sort_order: toggle_sort_order(:value),
              class: 'data'
  end
end
