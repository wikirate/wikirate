def sort_hash
  { sort_by: sort_by, sort_order: sort_order }
end

def sort_by
  @sort_by ||= safe_sql_param("sort_by") || default_sort_option
end

# override
def default_sort_option
  lookup? ? :value : :name
end

def lookup?
  !filter_hash[:status]&.to_sym.in? %i[none all]
end

def sort_order
  return unless sort_by
  @sort_order ||= safe_sql_param("sort_order")
  @sort_order ||= default_desc_sort_order.include?(sort_by) ? :desc : :asc
end

def default_desc_sort_order
  ::Set.new [:updated_at, :importance, :value]
end

format :html do
  def table_sort_link name, key, test=nil, css_class=""
    return name if test && !card.send(test)
    sort_link "#{name} #{sort_icon key}",
              sort_by: key,
              sort_order: toggle_sort_order(key),
              class: "#{css_class} table-sort-link table-sort-by-#{key}"
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
    return "asc" unless field.to_sym == card.sort_by.to_sym

    card.sort_order == "asc" ? "desc" : "asc"
  end

  def sort_icon field
    icon = "sort"
    icon += "-#{card.sort_order}" if field.to_sym == card.sort_by.to_sym
    fa_icon icon
  end
end
