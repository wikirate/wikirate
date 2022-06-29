include_set Abstract::Search
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
  def quick_filter_item hash, filter_key
    icon = hash.delete :icon
    super.tap do |item|
      item[:icon] = icon || mapped_icon_tag(filter_key)
    end
  end

  def export_formats
    [:json]
  end

  def export_link_path format
    super.merge filter_and_sort_hash
  end

  def default_item_view
    :bar
  end

  def filter_name_label
    card.respond_to?(:target_type_id) ? "#{card.target_type_id.cardname} Name" : "Name"
  end

  before :content do
    class_up "card-slot", "_filter-result-slot"
  end
end
