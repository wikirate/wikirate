include_set Abstract::FilterForm
include_set Abstract::MetricRecordFilter
format :html do
  def view_caching?
    false
  end

  def filter_categories
    # name implies 'company' name
    %w(keyword industry project)
  end

  def main_filter_categories
    %w(year metric_value)
  end

  def keyword_name
    "Company"
  end
end
