# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::ListRefCachedCount,
            type_to_count: :metric,
            list_field: :wikirate_topic

include_set Right::BrowseMetricFilter

def query_hash
  { topic: left.id }
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
