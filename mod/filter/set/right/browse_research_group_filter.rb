# filter interface for "Browse ResearchGroup" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm

def default_sort_option
  "researcher"
end

def filter_keys
  %i[name wikirate_topic]
end

def default_filter_option
  { name: "" }
end

def target_type_id
  ResearchGroupID
end

def filter_class
  ResearchGroupFilterQuery
end

format :html do
  def sort_options
    { "Most Researchers": :researcher, "Most Projects": :project }.merge super
  end
end

class ResearchGroupFilterQuery < FilterQuery
  include WikirateFilterQuery
end
