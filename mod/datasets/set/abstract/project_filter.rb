# filter interface for Projects

include_set Abstract::CqlSearch
include_set Abstract::SearchViews
include_set Abstract::BrowseFilterForm

def target_type_id
  ProjectID
end

format do
  def filter_class
    ProjectFilterQuery
  end

  def default_sort_option
    "create"
  end

  def filter_keys
    %i[name wikirate_status]
  end

  def default_filter_hash
    { name: "", wikirate_status: "Active" }
  end

  def sort_options
    { "Recently Added": :create,
      "Alphabetical": :name }
  end
end

format :html do
  view :filter_wikirate_status_formgroup, cache: :never do
    select_filter :wikirate_status, "Active"
  end

  def wikirate_status_options
    %w[Active Inactive]
  end
end

# cql query to filter sources
class ProjectFilterQuery < Card::FilterQuery
  def wikirate_status_cql value
    return unless value.present?
    add_to_cql :right_plus, [WikirateStatusID, { refer_to: value }]
  end
end
