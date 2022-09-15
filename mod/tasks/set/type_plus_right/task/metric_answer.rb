# include_set Type::SearchType
include_set Self::MetricAnswer
include_set Abstract::TaskFilter

format do
  # FIXME: this is a hard-coding of one task!
  def default_filter_hash
    { metric_name: "", company_name: "", verification: "flagged" }
  end
end

format :html do
  def show_chart?
    false
  end
end
