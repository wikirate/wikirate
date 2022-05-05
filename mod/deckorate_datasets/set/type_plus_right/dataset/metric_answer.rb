include_set Abstract::FullAnswerSearch
include_set Abstract::Chart

def dataset_name
  name.left_name
end

def query_hash
  { dataset: dataset_name }
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end
end
