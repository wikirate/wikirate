include_set Abstract::AllMetricValues

def query_class
  FixedMetricAnswerQuery
end

def default_sort_option
  :value
end

# tables used on a metric page
format :html do
  view :table, cache: :never do
    wikirate_table_with_details :company, self,
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

  view :filter do
    field_subformat(:metric_company_filter)._render_core
  end
end
