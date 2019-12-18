include_set Right::BrowseMetricFilter
include_set Type::SearchType

def type_id
  Card::SearchID
end

def default_sort_option
  "name"
end

def pointer_mark
  name.left
end

def wql_content
  { type_id: MetricID, referred_to_by: pointer_mark }
end
