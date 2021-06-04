include_set Right::BrowseMetricFilter

def query_hash
  { project: name.left }
end

format do
  def default_sort_option
    :metric_title
  end
end
