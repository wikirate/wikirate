include_set Abstract::AllMetricValues

def query_class
  FixedCompanyAnswerQuery
end

def default_sort_option
  :importance
end

format :html do
  view :core, cache: :never do
    bs_layout do
      row do
        _optional_render_filter
      end
      row do
        _render_table
      end
      row do
        nest card.left, view: :export_links
      end
    end
  end

  def table_args
    [:metric,
     self, # call search_with_params on self to get items
     [:metric_thumbnail_with_vote, :value_cell],
     header: [name_sort_links, "Value"],
     details_view: :metric_details_sidebar]
  end

  view :filter do
    field_subformat(:company_metric_filter)._render_core
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

  view :homepage_table do
    homepage_table :metric
  end
end
