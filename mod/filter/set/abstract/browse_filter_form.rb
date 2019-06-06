# used for the filters on the "browse ..." pages

include_set Abstract::Search
include_set Abstract::Filter
include_set Abstract::FilterFormgroups

def filter_keys
  []
end

def default_sort_option
  "name"
end

def filter_class
  Card::FilterQuery
end

def wql_from_content
  { type_id: target_type_id, limit: 20 }
end

def target_type_id
  raise "need target_type_id"
end

def sort_wql
  case current_sort.to_sym
  when :name
    { sort: "name" }
  when :create
    { sort: "create", dir: "desc" }
  else
    cached_count_sort_wql
  end
end

def cached_count_sort_wql
  { sort: { right: current_sort,
            item: "cached_count",
            return: "count" },
    sort_as: "integer",
    dir: "desc" }
end

def virtual?
  !real?
end

format :html do
  # view :no_search_results do
  #   wrap_with :div, "No result", class: "search-no-results"
  # end

  def default_item_view
    :bar
  end

  before :content do
    class_up "card-slot", "_filter-result-slot"
  end
end
