
format do
  def sort_dir
    return unless sort_by
    @sort_dir ||= safe_sql_param("sort_dir") || default_sort_dir(sort_by)
  end

  def default_sort_dir sort_by
    default_desc_sort_dir.include?(sort_by.to_sym) ? :desc : :asc
  end

  def default_desc_sort_dir
    ::Set.new %i[updated_at metric_bookmarkers value year]
  end

  def sort_hash
    { sort_by: sort_by, sort_dir: sort_dir }
  end

  def sort_by
    @sort_by ||= safe_sql_param("sort_by") || default_sort_option
  end

  def default_sort_option
    lookup? ? default_lookup_sort_option : :name
  end

  def default_lookup_sort_option
    single?(:year) ? :value : :year
  end

  def toggle_sort_dir field
    if field.to_sym == sort_by.to_sym
      opposite_sort_dir
    else
      default_sort_dir field
    end
  end

  def opposite_sort_dir
    sort_dir == "asc" ? "desc" : "asc"
  end

  def lookup?
    !filter_hash[:status]&.to_sym.in? %i[none all]
  end
end

format :html do
  def table_sort_link name, key, css_class=""
    sort_link "#{name} #{sort_icon key}",
              sort_by: key,
              sort_dir: toggle_sort_dir(key),
              class: "#{css_class} table-sort-link table-sort-by-#{key}"
  end

  # @param [String] text link text
  # @param [Hash] args sort args
  # @option args [String] :sort_by
  # @option args [String] :order
  # @option args [String] :class additional css class
  def sort_link text, args
    link_to_view :table, text, path: sort_path(args),
                               class: "metric-list-header #{args[:class]}"
  end

  def sort_path args
    paging_path_args sort_dir: args[:sort_dir], sort_by: args[:sort_by]
  end

  def sort_icon field
    icon = "sort"
    icon += "-#{sort_dir_arrow}" if field.to_sym == sort_by.to_sym
    fa_icon icon
  end

  def sort_dir_arrow
    sort_dir.to_sym == :asc ? :up : :down
  end
end
