# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::CachedCount
include_set Abstract::MetricFilter

def query_hash
  { topic: left_id }
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
