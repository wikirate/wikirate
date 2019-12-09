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

def partner
  :company
end

format :json do
  def chart_metric_id
    card.left.id
  end
end

format :html do
  def cell_views
    [:company_thumbnail_with_bookmark, :concise]
  end

  def header_cells
    [company_sort_links, render_answer_header]
  end

  def details_view
    :company_details_sidebar
  end

  def company_sort_links
    output [table_sort_link(rate_subjects, :company_name),
            table_sort_link("", :bookmarkers, "pull-left mx-3 px-1")]
  end

  def show_chart?
    super && count_by_status[:known].to_i.positive?
  end
end
