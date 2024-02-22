# cache # of metrics tagged with this topic (=_left) via <metric>+topic
include_set Abstract::CachedCount
include_set Abstract::MetricSearch

def query_hash
  { topic: left_id }
end

# trigger recount when metric's topic list is edited
recount_trigger :type_plus_right, :metric, :wikirate_topic do |topic_list|
  metric_fields_for_topics topic_list.changed_item_names
end

# ...or when metric is (un)published
field_recount_trigger :type_plus_right, :metric, :unpublished do |changed_card|
  metric_fields_for_topics changed_card.left.wikirate_topic_card.item_names
end

def self.metric_fields_for_topics topic_list
  topic_list.map { |item_name| Card.fetch item_name.to_name.field(:metric) }
end

format :html do
  def quick_filter_list
    bookmark_quick_filter
  end
end
