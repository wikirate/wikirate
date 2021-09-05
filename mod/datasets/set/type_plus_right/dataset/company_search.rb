def dataset_name
  name.left_name
end

def pointer_mark
  dataset_name.field :wikirate_company
end

def cql_content
  super.merge append: dataset_name
end

format :html do
  # don't add quick filters for other datasets
  def dataset_quick_filters
    []
  end

  def export_formats
    []
  end
end
