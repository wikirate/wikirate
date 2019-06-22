# Answer search for a given Metric
include_set Abstract::AnswerSearch
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Chart

def fixed_field
  :metric_id
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

  def partner
    :company
  end

  def cell_views
    [:company_thumbnail, :concise]
  end

  def header_cells
    [company_sort_link, render_answer_header]
  end

  def details_view
    :company_details_sidebar
  end

  def company_sort_link
    table_sort_link rate_subjects, :company_name
  end
end
