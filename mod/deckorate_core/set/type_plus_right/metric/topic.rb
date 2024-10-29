# cache # of topics metric (=_left) is tagged with
include_set Abstract::CachedCount
include_set Abstract::MetricChild, generation: 1

delegate :ok_to_delete?, to: :metric_card

def ok_item_types
  :topic
end

recount_trigger :type_plus_right, :metric, :topic do |changed_card|
  changed_card unless changed_card&.left&.trash
end
