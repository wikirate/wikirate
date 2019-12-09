include_set Right::BrowseMetricFilter

def bookmark_type
  :metric
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
