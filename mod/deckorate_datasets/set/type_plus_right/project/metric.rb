include_set Abstract::ProjectList
include_set Abstract::MetricSearch

def query_hash
  { dataset: dataset_name }
end

format do
  def default_sort_option
    :metric_title
  end

  def name_search
    card.search query: query, return: :name
  end

  def search_with_params
    with_dataset { name_search }
  end

  def with_dataset
    card.dataset_name.present? ? yield : []
  end

  def search_with_params
    @search_with_params ||= with_dataset do
      name_search.map do |metric_name|
        Card.fetch metric_name.field(card.project_name)
      end
    end
  end
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end
end
