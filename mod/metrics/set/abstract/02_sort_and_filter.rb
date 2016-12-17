include_set Abstract::Search
include_set Abstract::Utility
include_set Abstract::Filter

def virtual?
  true
end

# @return # of companies with values
def count _params={}
  item_cards.size
end

def limit
  20
end

format do
  # paging helper methods
  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    @paging_path_args[:view] = :content
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = paging_path_args @paging_path_args
    link_to raw(text), options
  end
end

format :html do
  view :card_list_item do |args|
    item_card = args[:item_card]
    item_view = args[:items] && args[:items][:view]
    nest(item_card, size: voo.size, view: item_view) do |result, viewname|
      %(<div class="search-result-item item-#{viewname}">#{result}</div>)
    end
  end

  view :card_list_items do |args|
    search_with_params.map do |row|
      item_card = item_card_from_row row
      render :card_list_item, args.clone.merge(item_card: item_card)
    end.join "\n"
  end

  view :card_list do |args|
    paging = _optional_render :paging, args
    if search_with_params.blank?
      render_no_search_results(args)
    else
      results = render :card_list_items, args
      header = render :card_list_header, args
      %(
      #{paging}
      #{header}
        <div class="search-result-list">
          #{results}
        </div>
        #{paging if search_with_params.length > 10}
      )
    end
  end

  view :card_list_header do
    ""
  end

  def item_card_from_row row
    Card.fetch row[0]
  end
end
