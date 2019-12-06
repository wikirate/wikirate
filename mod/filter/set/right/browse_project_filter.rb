# filter interface for "Browse Projects" page

include_set Type::SearchType
include_set Abstract::BrowseFilterForm
include_set Abstract::BookmarkFiltering

def filter_class
  ProjectFilterQuery
end

def default_sort_option
  "create"
end

def filter_keys
  %i[name wikirate_status wikirate_topic bookmark]
end

def default_filter_hash
  { name: "", wikirate_status: "Active" }
end

def target_type_id
  ProjectID
end

format :html do
  def sort_options
    { "Most Bookmarked": :bookmark,
      "Recently Added": :create,
      "Alphabetical": :name,
      "Most Subprojects": :subprojects,
      "Most Metrics": :metric,
      "Most Companies": :company }
  end

  view :filter_wikirate_status_formgroup, cache: :never do
    select_filter :wikirate_status, "Active"
  end

  def wikirate_status_options
    %w[Active Inactive]
  end
end

# cql query to filter sources
class ProjectFilterQuery < Card::FilterQuery
  include WikirateFilterQuery

  def wikirate_status_wql value
    return unless value.present?
    add_to_wql :right_plus, [WikirateStatusID, { refer_to: value }]
  end
end
