include_set Abstract::Search
include_set Abstract::Export

def virtual?
  new?
end

def cql_content
  { type_id: item_type_id, limit: 20 }
end

def item_type_id
  raise "need item_type_id"
end

format do
  def filter_cql_class
    Card::FilterCql
  end

  def default_sort_option
    "name"
  end

  def sort_cql
    case current_sort.to_sym
    when :name, :id, :relevance
      { sort_by: current_sort.to_s }
    when :create
      { sort_by: "create", dir: "desc" }
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

  def filtering_by_published
    yield.tap { |arr| arr << :published if Card::Auth.current.stewards_any? }
  end
end

format :html do
  view :filtered_results_stats, cache: :never do
    labeled_badge count_with_params, card.item_type_name.vary(:plural)
  end

  def quick_filter_item hash, filter_key
    icon = hash.delete :icon
    super.tap do |item|
      item[:icon] = icon || icon_tag(filter_key)
    end
  end

  def export_link_path_args format
    super.merge filter_and_sort_hash
  end

  def default_item_view
    :bar
  end

  def filter_name_label
    "#{card.item_type_name} Name"
  end

  before :content do
    class_up "card-slot", "_filter-result-slot"
  end
end
