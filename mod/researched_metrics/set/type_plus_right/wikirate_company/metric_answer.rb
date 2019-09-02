# Answer search for a given Company
include_set Abstract::AnswerSearch

def fixed_field
  :company_id
end

def filter_card_fieldcode
  :company_metric_filter
end

def default_sort_option
  record? ? :year : :importance
end

def partner
  :metric
end

format :html do
  before :core do
    voo.hide! :chart
    super()
  end

  def cell_views
    [:metric_thumbnail_with_vote, :concise]
  end

  def header_cells
    [name_sort_links, render_answer_header]
  end

  def details_view
    :metric_details_sidebar
  end

  def name_sort_links
    "#{importance_sort_link}#{designer_sort_link}#{title_sort_link}"
  end

  def title_sort_link
    table_sort_link "Metric", :title_name, "pull-left mx-3 px-1"
  end

  def designer_sort_link
    table_sort_link "", :metric_name, "pull-left mx-3 px-1"
  end

  def importance_sort_link
    table_sort_link "", :importance, "pull-left mx-3 px-1"
  end
end
