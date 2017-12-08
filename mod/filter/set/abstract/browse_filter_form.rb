# used for the filters on the "browse ..." pages

include_set Type::SearchType
include_set Abstract::Filter

def filter_keys
  %i[metric designer wikirate_topic project year]
end

def sort?
  true
end

def default_sort_by_key
  "metric"
end

def filter_class
  Card::FilterQuery
end

def filter_wql
  filter_class.new(filter_keys_with_values, extra_filter_args).to_wql
end

def extra_filter_args
  ignoring_blocked_ids do
    { type_id: target_type_id }
  end
end

def ignoring_blocked_ids
  hash = yield
  if (not_ids = blocked_ids)
    hash[:id] = ["not in", not_ids]
  end
  hash
end

def blocked_ids
  not_ids = filter_param :not_ids
  return unless not_ids.present?
  not_ids.split ","
end

def target_type_id
  WikirateCompanyID
end

def wql_hash
  @wql = begin
    wql = filter_wql
    wql[:limit] = 20
    add_sort_wql wql, sort_param if sort?
    wql
  end
end

def add_sort_wql wql, sort_by
  wql.merge!(
    if sort_by == "name"
      { sort: "name" }
    else
      cached_count_sort_wql(sort_by)
    end
  )
end

def cached_count_sort_wql sort_by
  { sort: { right: (sort_by || default_sort_by_key),
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

  def default_select_item_args _args
    class_up "card-slot", "_filter-result-slot"
  end

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
