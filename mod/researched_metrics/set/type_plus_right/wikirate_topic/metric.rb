include_set Right::BrowseMetricFilter

# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::TaggedByCachedCount,
            type_to_count: :metric, tag_pointer: :wikirate_topic

def bookmark_type
  :metric
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
