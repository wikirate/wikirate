def sort_hash
  { sort_by: sort_by, sort_order: sort_order }
end

def default_desc_sort_order
  ::Set.new [:updated_at, :importance, :value]
end

def sort_by
  @sort_by ||= safe_sql_param("sort_by") || default_sort_option
end

# override
def default_sort_option
  :value
end

def sort_order
  return unless sort_by
  @sort_order ||= safe_sql_param("sort_order")
  @sort_order ||= default_desc_sort_order.include?(sort_by) ? :desc : :asc
end

format do
  def sort values
    values
  end

  def sorted_result
    sort card.filtered_values_by_name
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
    Answer.unknown? value
  end

  def latest_year_value values
    values.sort_by { |value| value["year"] }.reverse[0]["value"]
  end
end

format :html do
  def table_sort_link name, key, css_class=""
    sort_link "#{name} #{sort_icon key}",
              sort_by: key,
              sort_order: toggle_sort_order(key),
              class: css_class
  end

  # @param [String] text link text
  # @param [Hash] args sort args
  # @option args [String] :sort_by
  # @option args [String] :order
  # @option args [String] :class additional css class
  def sort_link text, args
    path = paging_path_args sort_order: args[:sort_order],
                            sort_by: args[:sort_by]
    link_to_view :filter_result, text,
                 path: path,
                 class: "metric-list-header #{args[:class]}"
  end

  def toggle_sort_order field
    if field.to_sym == card.sort_by.to_sym
      card.sort_order == "asc" ? "desc" : "asc"
    else
      "asc"
    end
  end

  def sort_icon field
    icon = "sort"
    icon += "-#{card.sort_order}" if field.to_sym == card.sort_by.to_sym
    fa_icon icon
  end
end
