# used for the filters on the "browse ..." pages

include_set Abstract::Search
include_set Abstract::Filter
include_set Abstract::WikirateFilter
include_set Abstract::FilterFormgroups
include_set Abstract::Export

def virtual?
  new?
end

def cql_content
  { type_id: target_type_id, limit: 20 }
end

def target_type_id
  raise "need target_type_id"
end

format do
  def filter_class
    Card::FilterQuery
  end

  def filter_keys
    []
  end

  def default_sort_option
    "name"
  end

  def sort_cql
    case current_sort.to_sym
    when :name
      { sort: "name" }
    when :create
      { sort: "create", dir: "desc" }
    when :relevance
      { sort: "relevance" }
    else
      cached_count_sort_cql
    end
  end

  def cached_count_sort_cql
    { sort: { right: current_sort,
              item: "cached_count",
              return: "count" },
      sort_as: "integer",
      dir: "desc" }
  end
end

format :html do
  def export_formats
    [:json]
  end

  def default_item_view
    :bar
  end

  before :content do
    class_up "card-slot", "_filter-result-slot"
  end
end
