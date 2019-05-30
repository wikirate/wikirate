# filter interface for "Browse ResearchGroup" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm

def filter_class
  ResearchGroupFilterQuery
end

def default_sort_option
  "researcher"
end

def filter_keys
  %i[name]
end

def default_filter_option
  { name: "" }
end

def target_type_id
  ResearchGroupID
end

format :html do
  def sort_options
    { "Most Researchers": "researcher" }.merge super
  end
end

# cql query to filter research groups
class ResearchGroupFilterQuery < Card::FilterQuery
end
