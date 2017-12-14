# used for the filters on the "browse ..." pages

include_set Type::SearchType
include_set Abstract::Filter

def filter_keys
  %i[metric designer wikirate_topic project year]
end

def default_sort_option
  "metric"
end

def filter_class
  Card::FilterQuery
end

def content
  { type_id: target_type_id, limit: 20 }.merge sort_wql
end

def target_type_id
  WikirateCompanyID
end

def sort_wql
  if current_sort == "name"
    { sort: "name" }
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
  true
end

format :html do
  # view :no_search_results do |_args|
  #   wrap_with :div, "No result", class: "search-no-results"
  # end

  def default_content_args _args
    class_up "card-slot", "_filter-result-slot"
  end

  def filter_action_path
    path
  end

  view :filter_form, cache: :never do
    filter_fields slot_selector: "._filter-result-slot",
                  sort_field: _render(:sort_formgroup)
  end
end
