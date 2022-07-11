# These Dataset+Metric (type plus right) cards refer to the list of
# all companies on a given dataset.

include_set Abstract::MetricSearch
include_set Abstract::DatasetScope
include_set Abstract::IdPointer

def query_hash
  ids = item_ids
  ids = [-1] if ids.empty?
  { metric_id: ids }
end

# act like list not search
def item_cards *args
  standard_item_cards *args
end

format :html do
  view :titled_content do
    render_filtered_content
  end
end
