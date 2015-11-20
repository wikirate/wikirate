include Card::CachedCount
include Type::SearchType

def virtual?; true end

def raw_content
  %{
    {
      "left":{
        "type":"metric_value",
        "left":{
          "left":"_left"
        }
      },
      "right":"value",
      "limit":0
    }
  }
end

def get_sort_params
  [
    (Env.params["sort_by"]||"company_name"),
    (Env.params["sort_order"]||"asc")
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
  if !default_query
    @query[:limit] = params[:default_limit] || 20
    @query[:offset] = get_params("offset", 0)
  end
  @query
end

def get_cached_result
  @cached_metric_values ||= begin
    cached_json = fetch(trait: :cached_count, new: {}).format.render_core
    JSON.parse(cached_json)
  end
end

def count params={}
  get_cached_result.size
end

format do
  include Type::SearchType::Format

  def page_link text, page, _current=false, options={}
    @paging_path_args[:offset] = page * @paging_limit
    options.merge!(class: 'card-paging-link slotter', remote: true)
    sort_by, sort_order = card.get_sort_params
    paging_args = @paging_path_args.merge({sort_by: sort_by,
                                           sort_order: sort_order})
    link_to raw(text), path(paging_args), options
  end

  def sort_value_asc cached_metric_values, is_num
    cached_metric_values.sort do |x, y|
      value_a = x[1].sort_by { |value| value['year'] }.reverse[0]['value']
      value_b = y[1].sort_by { |value| value['year'] }.reverse[0]['value']
      if is_num
        dec_value_a = BigDecimal.new(value_a)
        dec_value_b = BigDecimal.new(value_b)
        if dec_value_a == dec_value_b
          0
        elsif dec_value_a > dec_value_b
          1
        else
          -1
        end
      else
        value_a <=> value_b
      end
    end
  end

  def sort_name_asc cached_metric_values
    cached_metric_values.sort do |x,y|
      x[0].downcase <=> y[0].downcase
    end
  end

  def get_sorted_result cached_metric_values, sort_by, order, is_num
    case sort_by
    when "company_name"
      if order == "asc"
        sort_name_asc cached_metric_values
      else
        sort_name_asc(cached_metric_values).reverse
      end
    when "value"
      if order == "asc"
        sort_value_asc cached_metric_values, is_num
      else
        sort_value_asc(cached_metric_values, is_num).reverse
      end
    end
  end

  def search_results args={}
    @search_results ||= begin
      sort_by, sort_order = card.get_sort_params
      offset = card.get_params('offset', 0)
      limit = card.query(search_params)[:limit]
      cached_result = card.get_cached_result
      metric_value_type = Card["#{card.cardname.left}+metric value type"]
      type = metric_value_type.nil? ? '' : metric_value_type.item_names[0]
      num = (type == 'Number' || type == 'Monetory')
      # binding.pry
      all_results = get_sorted_result(cached_result, sort_by, sort_order, num)
      all_results[offset, limit]
    end
  end

end
format :html do
  include Type::SearchType::HtmlFormat
  def get_sort_icon_by_state state
    order = state.empty? ? '' : "-#{state}"
    %{<i class="fa fa-sort#{order}"></i>}
  end

  def toggle_sort_order order
    order == 'asc' ? 'desc' : 'asc'
  end

  def get_sort_order sort_by, sort_order
    if sort_by == 'company_name'
      [toggle_sort_order(sort_order), 'asc']
    else
      ['asc', toggle_sort_order(sort_order)]
    end
  end

  def get_sort_icon sort_by, sort_order
    if sort_by == 'company_name'
      [get_sort_icon_by_state(sort_order), get_sort_icon_by_state('')]
    else
      [get_sort_icon_by_state(''), get_sort_icon_by_state(sort_order)]
    end
  end

  view :card_list_header do |args|
    sort_by, sort_order = card.get_sort_params
    offset = card.get_params('offset', 0)
    limit = card.query(search_params)[:limit]
    company_sort_order, value_sort_order = get_sort_order sort_by, sort_order
    company_sort_icon, value_sort_icon = get_sort_icon sort_by, sort_order
     
    url_template = "/#{card.cardname.url_key}?item=content&offset=#{offset}"\
                   "&limit=#{limit}&sort_order=%s&sort_by=%s"
    %{
      <div class='yinyang-row column-header'>
        <div class='company-item value-item'>
          <a class='header metric-list-header slotter' data-remote='true'
            href='#{sprintf(url_template, company_sort_order, 'company_name')}'>
            Companies #{company_sort_icon}
          </a>
          <a class='data metric-list-header slotter' data-remote='true'
            href='#{sprintf(url_template, value_sort_order, 'value')}'>
            Values #{value_sort_icon}
          </a>
        </div>
      </div>
    }
  end
  # compare lenght first and then normal string comparison
  # def strcmp str1, str2
  #   if (length_diff = str1.length - str2.length) == 0
  #     str1 <=> str2
  #   else
  #     length_diff
  #   end

  # end

  view :card_list_item do |args|
    c = args[:item_card]
    item_view = inclusion_defaults(c)[:view]
    %(
      <div class="search-result-item item-#{item_view}">
        #{nest(c, size: args[:size], view: item_view)}
      </div>
    )
  end

  view :card_list_items do |args|
    results =
      search_results.map do |row|
        c = Card["#{card.cardname.left}+#{row[0]}"]
        render :card_list_item, args.clone.merge(item_card: c)
      end.join "\n"
  end

  view :card_list do |args|
    paging = _optional_render :paging, args
    if search_results.empty?
      render_no_search_results(args)
    else
      results = render :card_list_items, args
      header = render :card_list_header, args
      %{
        #{paging}
        #{header}
        <div class="search-result-list">
          #{results}
        </div>
        #{paging if search_results.length > 10}
      }
    end
  end
end

def cached_count
  cached_count_card.content
end

expired_cached_count_cards do |changed_card|
  case changed_card.type_id
  when MetricValueID
    changed_card = changed_card.left.left.fetch(trait: :all_values)
    changed_card.update_cached_count if changed_card
  when WikirateCompanyID
    metrics = Card.search type_id: MetricID, right_plus: changed_card.name
    metrics.each do |metric|
      changed_card = metric.fetch(trait: :all_values)
      changed_card.update_cached_count if changed_card
    end
  when MetricID
    changed_card = changed_card.fetch(trait: :all_values)
    changed_card.update_cached_count if changed_card
  end

end

# get all metric values
def calculate_count
  result = {}
  item_cards(default_query: true).each do |card|
    company_name = card.left.left.cardname.right
    year = card.cardname.parts[-2]
    value = card.content
    result[company_name] = [] unless result.key?(company_name)
    result[company_name].push(year: year, value: value)
  end
  result.to_json
end


