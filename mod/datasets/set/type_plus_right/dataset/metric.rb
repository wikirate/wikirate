# These Dataset+Metric (type plus right) cards refer to the list of
# all companies on a given dataset.
include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::FilterList
include_set Right::BrowseMetricFilter
include_set Abstract::DatasetScope
include_set Abstract::IdPointer

format :html do
  def filter_field_code
    :browse_metric_filter
  end
end
