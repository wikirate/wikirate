# cache # of topics metric (=_left) is tagged with
include_set Abstract::CachedCount
include_set Abstract::MetricChild, generation: 1

delegate :ok_to_delete?, to: :metric_card

event :cascade_topics, :finalize, changed: :content do
  Auth.as_bot do
    cascade_calculated_topics
  end
end

recount_trigger :type_plus_right, :metric, :topic do |changed_card|
  changed_card unless changed_card&.left&.trash
end

def ok_item_types
  :topic
end

# used by calculated metrics to infer license from its inputs
def infer
  return false unless metric_card.calculated?

  topics = metric_card.direct_dependee_metrics.map do |metric|
    metric.topic_card.item_names
  end
  update content: topics.flatten.uniq
end

private

def cascade_calculated_topics
  metric_card.direct_depender_metrics.each do |metric|
    metric.topic_card.infer
  end
end
