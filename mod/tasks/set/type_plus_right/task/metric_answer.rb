include_set Type::SearchType
include_set Self::MetricAnswer
include_set Abstract::TaskFilter

format do
  def default_filter_hash
    { metric_name: "", company_name: "", verification: "flagged" }
  end
end

format :html do
  def show_chart?
    false
  end

  def details_view
    :details_sidebar
  end
end
