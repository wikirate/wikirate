include_set Type::SearchType
include_set Abstract::ProjectList
include_set Right::BrowseMetricFilter

def query_hash
  { dataset: dataset_name }
end

format do
  def default_sort_option
    :metric_title
  end

  def search_with_params
    @search_with_params ||= card.search(query: query, return: :name).map do |metric_name|
      Card.fetch metric_name.field(card.project_name)
    end
  end
end

format :html do
  def standard_filter_keys
    super - [:dataset]
  end

  def default_item_view
    :info_bar
  end

  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end

  def export_formats
    []
  end
end
