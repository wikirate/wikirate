include_set Right::BrowseMetricFilter

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end

  def bookmark_type
    :metric
  end
end