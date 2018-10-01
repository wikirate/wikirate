include_set Abstract::AllMetricValues
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Chart

def query_class
  FixedMetricAnswerQuery
end

def default_sort_option
  :value
end

format :json do
  def chart_metric_id
    card.left.id
  end
end

# tables used on a metric page
format :html do
  view :core do
    voo.show! :chart
    super()
  end

  def table_args
    [:company,
     self,
     [:company_thumbnail, :value_cell],
     header: [company_sort_link, value_sort_link],
     details_view: :company_details_sidebar]
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

  view :homepage_table do
    homepage_table :company
  end
end
