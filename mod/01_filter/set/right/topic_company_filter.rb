include_set Abstract::CollapsedFilterForm

def filter_keys
  %w(wikirate_company)
end

format :html do
  def content_view
    :company_tab
  end

  def sort_options
    {
      "Most Metrics" => "most_metrics",
      "Most Notes" => "most_notes",
      "Most Sources " => "most_sources",
      "Has Overview" => "has_overview"
    }
  end

  def default_sort_option
    "most_metrics"
  end
end
