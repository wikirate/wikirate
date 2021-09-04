include_set Right::BrowseMetricFilter

def query_hash
  { dataset: name.left }
end

format do
  def default_sort_option
    :metric_title
  end
end
