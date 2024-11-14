include_set Abstract::FullAnswerSearch
include_set Abstract::TaskFilter

format do
  # FIXME: this is a hard-coding of one task!
  def default_filter_hash
    { metric_keyword: "", company_name: "", verification: "flagged" }
  end
end

format :html do
  def show_chart?
    false
  end
end
