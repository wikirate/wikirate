# These Dataset+Metric (type plus right) cards refer to the list of
# all companies on a given dataset.
include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Right::BrowseMetricFilter
include_set Abstract::DatasetScope
include_set Abstract::IdPointer
include_set Abstract::FilterList

def query_hash
  ids = item_ids
  ids = [-1] if ids.empty?
  { metric_id: ids }
end

format :html do
  view :titled_content do
    render_filtered_content
  end

  def filter_field_code
    :browse_metric_filter
  end
end
