include_set Abstract::RecordFilters

assign_type :search_type

def content_type
  Card::Name[cql_content[:type_id] || cql_content[:type]]
end

def filter_search_name
  Card::Name[name.left, content_type]
end

format :html do
  view :core do
    nest card.filter_search_name, view: :filtered_content, hide: :paging
  end
end
