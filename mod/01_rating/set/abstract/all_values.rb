include_set Type::SearchType
include_set Abstract::Utility
include_set Abstract::FilterUtility
include_set Abstract::MetricChild, generation: 1

def virtual?
  true
end

def wql_to_identify_related_metric_values
  '"left": { "left":"_left" }'
end

def raw_content
  %({
      "left":{
        "type":"metric_value",
        #{wql_to_identify_related_metric_values}
      },
      "right":"value",
      "limit":0
    })
end

def sort_params
  [
    (Env.params["sort_by"] || "value"),
    (Env.params["sort_order"] || "desc")
  ]
end

def get_params key, default
  if (value = Env.params[key])
    value.to_i
  else
    default
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

# @return [Hash] all companies with year and values
#  format: { <company name> => { :year =>  , :value => }}
def filtered_values_by_name
  @filtered_values_by_name ||= filter values_by_name
end

def params_keys
  %w(name industry project)
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

format :json do
  view :core do |_args|
    mvc = MetricValuesHash.new card.left
    card.item_cards(default_query: true).each do |value_card|
      mvc.add value_card
    end
    mvc.to_json
  end
end

format do
  def page_link_params
    []
  end

  def fill_paging_args
    sort_by, sort_order = card.sort_params
    paging_args = @paging_path_args.merge(sort_by: sort_by,
                                          sort_order: sort_order)
    page_link_params.each do |key|
      paging_args[key] = params[key] if params[key].present?
    end
    paging_args[:view] = :content
    paging_args
  end

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options[:class] = "card-paging-link slotter"
    options[:remote] = true
    paging_args = fill_paging_args
    link_to raw(text), path(paging_args), options
  end

  def unknown_value? value
    value.casecmp("unknown").zero?
  end

  def compare_content value_a, value_b, is_num
    if is_num && !(unknown_value?(value_a) || unknown_value?(value_b))
      BigDecimal.new(value_a) - BigDecimal.new(value_b)
    else
      value_a <=> value_b
    end
  end

  def latest_year_value values
    values.sort_by { |value| value["year"] }.reverse[0]["value"]
  end

  def sort_value_asc metric_values, is_num
    return metric_values.to_a if Env.params["value"] == "none"
    metric_values.sort do |x, y|
      value_a = latest_year_value x[1]
      value_b = latest_year_value y[1]
      compare_content value_a, value_b, is_num
    end
  end

  def sort_name_asc metric_values
    metric_values.sort do |x, y|
      x[0].downcase <=> y[0].downcase
    end
  end

  def offset
    card.get_params("offset", 0)
  end

  def limit
    card.query(search_params)[:limit]
  end

  def sorted_result sort_by, order, is_num=true
    sorted = case sort_by
             when "name", "company_name"
               sort_name_asc card.filtered_values_by_name
             else # "value"
               sort_value_asc card.filtered_values_by_name, is_num
             end
    return sorted if order == "asc"
    sorted.reverse
  end

  def num?
    metric_card = card.left
    metric_value_type = metric_card.value_type_card
    type = metric_value_type.nil? ? "" : metric_value_type.item_names[0]
    type == "Number" || type == "Money" || !metric_card.researched?
  end

  def search_results _args={}
    @search_results ||= begin
      sort_by, sort_order = card.sort_params
      all_results = sorted_result sort_by, sort_order, num?
      results = all_results[offset, limit]
      results.blank? ? [] : results
    end
  end
end

format :html do
  def sort_icon_by_state state
    order = state.empty? ? "" : "-#{state}"
    %(<i class="fa fa-sort#{order}"></i>)
  end

  def toggle_sort_order order
    order == "asc" ? "desc" : "asc"
  end

  def sort_order sort_by, sort_order
    if sort_by == "name"
      [toggle_sort_order(sort_order), "asc"]
    else
      ["asc", toggle_sort_order(sort_order)]
    end
  end

  def sort_icon sort_by, sort_order
    if sort_by == "name"
      [sort_icon_by_state(sort_order), sort_icon_by_state("")]
    else
      [sort_icon_by_state(""), sort_icon_by_state(sort_order)]
    end
  end

  # @param [String] text link text
  # @param [Hash] args sort args
  # @option args [String] :sort_by
  # @option args [String] :order
  # @option args [String] :class additional css class
  def sort_link text, args
    url = path view: "content", offset: offset, limit: limit,
               sort_order: args[:order], sort_by: args[:sort_by]
    link_to text, url, class: "metric-list-header slotter #{args[:class]}",
                       "data-remote" => true
  end

  view :card_list_header do
    sort_by, sort_order = card.sort_params
    company_sort_order, value_sort_order = sort_order sort_by, sort_order
    company_sort_icon, value_sort_icon = sort_icon sort_by, sort_order
    %(
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          #{sort_link "Companies #{company_sort_icon}",
                      sort_by: 'name', order: company_sort_order,
                      class: 'header'}
          #{sort_link "Values #{value_sort_icon}",
                      sort_by: 'value', order: value_sort_order,
                      class: 'data'}
        </div>
      </div>
    )
  end

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
      c = Card.fetch "#{card.cardname.left}+#{row[0]}"
      render :card_list_item, args.clone.merge(item_card: c)
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
end
