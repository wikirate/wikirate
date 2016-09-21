def sort_params
  [
    (Env.params["sort_by"] || "value"),
    (Env.params["sort_order"] || "desc")
  ]
end

format do
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

  def compare_content value_a, value_b, is_num
    if is_num && !(unknown_value?(value_a) || unknown_value?(value_b))
      BigDecimal.new(value_a) - BigDecimal.new(value_b)
    else
      value_a <=> value_b
    end
  end

  def unknown_value? value
    value.casecmp("unknown").zero?
  end

  def latest_year_value values
    values.sort_by { |value| value["year"] }.reverse[0]["value"]
  end
end

format :html do
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
end
