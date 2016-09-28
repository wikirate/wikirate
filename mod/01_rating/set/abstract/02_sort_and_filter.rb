include_set Type::SearchType
include_set Abstract::Utility
include_set Abstract::FilterUtility

def virtual?
  true
end

# @return [Hash] all companies with year and values
#  format: { <company name> => { :year =>  , :value => }}
def filtered_values_by_name
  @filtered_values_by_name ||= filter values_by_name
end

def values_by_id
  json = format(:json)._render_core
  (JSON.parse(json) || {}).with_indifferent_access
end

def values_by_name
  values_hash = values_by_id
  values_hash.keys.each do |key|
    mark = key.number? ? key.to_i : key
    next unless (card = Card.quick_fetch mark)
    values_hash[card.name] = values_hash.delete key
  end
  values_hash
end

# @return # of companies with values
def count _params={}
  filtered_values_by_name.size
end

format do
  def search_results _args={}
    @search_results ||= begin
      results = sorted_result[offset, limit]
      results.blank? ? [] : results
    end
  end

  def num?
    metric_card = card.left
    metric_value_type = metric_card.value_type_card
    type = metric_value_type.nil? ? "" : metric_value_type.item_names[0]
    type == "Number" || type == "Money" || !metric_card.researched?
  end

  def limit
    card.query(search_params)[:limit]
  end

  def offset
    card.get_params("offset", 0)
  end

  # paging helper methods
  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    options[:path] = fill_paging_args
    link_to raw(text), options
  end

  def fill_paging_args
    paging_args = @paging_path_args.merge(sort_by: sort_by,
                                          sort_order: sort_order)
    fill_page_link_params paging_args
    paging_args[:view] = :content
    paging_args
  end

  def fill_page_link_params paging_args
    page_link_params.each do |key|
      paging_args[key] = params[key] if params[key].present?
    end
  end

  def page_link_params
    []
  end
end

def query params={}
  default_query = params.delete :default_query
  @query = super params
  unless default_query
    @query[:limit] = params[:default_limit] || 20
    @query[:offset] = get_params("offset", 0)
  end
  @query
end

def get_params key, default
  if (value = Env.params[key])
    value.to_i
  else
    default
  end
end

format :html do
  view :card_list_item do |args|
    c = args[:item_card]
    item_view = args[:items] && args[:items][:view] || nest_defaults(c)[:view]
    %(
      <div class="search-result-item item-#{item_view}">
        #{nest(c, size: args[:size], view: item_view)}
      </div>
    )
  end

  view :card_list_items do |args|
    search_results.map do |row|
      item_card = item_card_from_row row
      render :card_list_item, args.clone.merge(item_card: item_card)
    end.join "\n"
  end

  view :card_list do |args|
    paging = _optional_render :paging, args
    if search_results.blank?
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
        #{paging if search_results.length > 10}
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
