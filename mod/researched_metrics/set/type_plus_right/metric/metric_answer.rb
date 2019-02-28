# Answer search for a given Metric
include_set Abstract::AnswerSearch
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Chart

def query_class
  FixedMetricAnswerQuery
end

def filter_card_fieldcode
  :metric_company_filter
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
    table_sort_link rate_subjects, :company_name
  end

  def value_sort_link
    table_sort_link "Values", :value
  end
end
