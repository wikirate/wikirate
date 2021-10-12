format do
  SORT_OPTIONS = ::Set.new(
    %i[metric_bookmarkers metric_designer metric_title
       company_bookmarkers company_name name
       year
       value numeric_value ]
  )

  SECONDARY_SORT = {
    metric_bookmarkers: { metric_title: :asc },
    metric_designer: { metric_title: :asc },
    company_bookmarkers: { company_name: :asc }
  }.freeze

  def sort_hash
    primary = { sort_by.to_sym => sort_dir }
    secondary_sort ? primary.merge(secondary_sort) : primary
  end

  def default_sort_dir sort_by
    return super unless sort_by == :value

    :default_value_sort_dir
  end

  def default_desc_sort_dir
    ::Set.new %i[updated_at metric_bookmarkers value year]
  end

  def secondary_sort
    @secondary_sort ||= secondary_sort_hash[sort_by]
  end

  # for override
  def secondary_sort_hash
    SECONDARY_SORT
  end

  def sort_by_from_param
    super.tap do |sort_by|
      if sort_by && !SORT_OPTIONS.include?(sort_by)
        raise Error::UserError, "Invalid Sort Param: #{sort_by}"
      end
    end
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
    return true if @answer_table_only

    !AnswerQuery.all_answer_query?(filter_hash.symbolize_keys)
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
    sort_dir.to_sym == :asc ? :down : :up
  end

  def company_sort_links
    "#{bookmarkers_sort_link :company}#{company_name_sort_link}"
  end

  def metric_sort_links
    "#{bookmarkers_sort_link :metric}#{designer_sort_link}#{title_sort_link}"
  end

  def answer_sort_links
    "#{value_sort_link}#{year_sort_link}"
  end

  def title_sort_link
    table_sort_link "Metric", :metric_title, "float-left mx-3 px-1"
  end

  def designer_sort_link
    table_sort_link "", :metric_designer, "float-left mx-3 px-1"
  end

  def bookmarkers_sort_link type
    table_sort_link "", :"#{type}_bookmarkers", "float-left mx-3 px-1"
  end

  def company_name_sort_link
    table_sort_link rate_subjects, :company_name, "float-left mx-5 px-4"
  end

  def value_sort_link
    table_sort_link "Answer", :value, "float-left mx-3 px-1"
  end

  def year_sort_link
    table_sort_link "Year", :year, "float-right mx-3 px-1"
  end
end
