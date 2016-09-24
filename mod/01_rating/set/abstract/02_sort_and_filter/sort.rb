format do
  def sort_by
    @sort_by ||= Env.params["sort_by"] || "value"
  end

  def sort_order
    @sort_order ||= Env.params["sort_order"] || "desc"
  end

  def sorted_result
    sorted = case sort_by
             when "name", "company_name"
               sort_name_asc card.filtered_values_by_name
             else # "value"
               sort_value_asc card.filtered_values_by_name, num?
             end
    sort_order == "asc" ? sorted : sorted.reverse
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
    path = { offset: offset, sort_order: args[:order],
             limit: limit,   sort_by:    args[:sort_by] }
    fill_page_link_params path
    link_to_view :content, text,
                 path: path,
                 class: "metric-list-header slotter #{args[:class]}"
  end

  def toggle_sort_order field
    if field.to_sym == sort_by.to_sym
      sort_order == "asc" ? "desc" : "asc"
    else
      "asc"
    end
  end

  def sort_icon field
    icon = "sort"
    icon += "-#{sort_order}" if field.to_sym == sort_by.to_sym
    fa_icon icon
  end
end
