include_set Abstract::SortAndFilter
include_set Abstract::MetricChild, generation: 1

def item_cards _args={}
  @item_cards ||= filtered_item_query(
    filter_hash, sort_hash, paging_hash
  ).run
end

def filtered_item_query filter={}, sort={}, paging={}
  return query_class.default left.id, sort, paging unless filter.present?
  query_class.new left.id, filter, sort, paging
end


format :json do
  view :core do
    mvh = MetricValuesHash.new card.left
    card.item_cards(default_query: true).each do |value_card|
      mvh.add value_card
    end
    mvh.to_json
  end
end
