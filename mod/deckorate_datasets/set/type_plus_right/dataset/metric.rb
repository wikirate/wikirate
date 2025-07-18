# These Dataset+Metric (type plus right) cards refer to the list of
# all companies on a given dataset.

include_set Abstract::MetricSearch
include_set Abstract::DatasetScope
include_set Abstract::IdList

event :re_infer_topics_and_license, :finalize, on: :save, changed: :content do
  left.topic_card.infer
  left.license_card.infer
end

def query_hash
  ids = item_ids
  ids = [-1] if ids.empty?
  { metric_id: ids }
end

# act like list not search
def item_cards *args
  standard_item_cards(*args)
end
