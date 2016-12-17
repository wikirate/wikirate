include_set Abstract::SortAndFilter
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Chart
include_set Abstract::Table

def search args={}
  return_type = args.delete :return
  q = query(args)
  case return_type
  when :name then
    q.run.map(&:name)
  when :count then
    q.count
  else
    q.run
  end
end

format :html do
  def search_results
    card.item_cards
  end

  view :core do
    bs_layout do
      row do
        _optional_render_filter
      end
      row class: "text-center" do
        _render_chart
      end
      row do
        _render_table
      end
    end
  end
end

def query args={}
  if filter_hash.present?
    query_class.new left.id, filter_hash, sort_hash, args
  else
    query_class.default left.id, sort_hash, args
  end
end

format do
  def extra_paging_path_args
    { filter: filter_hash }.merge sort_hash
  end
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
