include_set Abstract::FullAnswerSearch
include_set Abstract::Chart

def dataset_name
  name.left_name
end

def query_hash
  { dataset: dataset_name }
end

format do
  # TODO: make it so we can filter by other datasets
  def filter_map
    filter_map_without_keys super, :dataset
  end
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end
end
