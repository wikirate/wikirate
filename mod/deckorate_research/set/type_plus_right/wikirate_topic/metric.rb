# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::CachedCount
include_set Abstract::MetricSearch

def query_hash
  { topic: left_id }
end

recount_trigger :type_plus_right, :metric, :wikirate_topic do |topic_list|
  topic_list.changed_item_names.map do |item_name|
    Card.fetch item_name.to_name.field(:metric)
  end
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
