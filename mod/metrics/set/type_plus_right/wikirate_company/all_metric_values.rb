# All Answers for a given Company

include_set Abstract::AllMetricValues

def query_class
  FixedCompanyAnswerQuery
end

def default_sort_option
  :importance
end

format :html do
  view :filter_result, cache: :never do |_args|
    voo.hide! :chart
    super(_args)
  end

  def table_args
    [:metric,
     self, # call search_with_params on self to get items
     [:metric_thumbnail_with_vote, :value_cell],
     header: [name_sort_links, "Value"],
     details_view: :metric_details_sidebar]
  end

  view :filter do
    # filter_form a: { input_field: "<input class='a'/>", label: "A" },
    #            b: { input_field: "<formgroup><select class='b'><option value='a'>Alpha</option></select></formgroup>", label: "B" }
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
