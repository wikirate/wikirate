format do
  SORT_OPTIONS = ::Set.new(
    %i[metric_bookmarkers metric_designer metric_title
       company_bookmarkers company_name name
       year answer_count year_count
       value numeric_value ]
  )

  SECONDARY_SORT = {
    metric_bookmarkers: { metric_title: :asc },
    metric_designer: { metric_title: :asc },
    company_bookmarkers: { company_name: :asc }
  }.freeze

  SORT_TITLES = {
    company_name: "Company",
    metric_title: "Metric",
    answer_count: "Data points",
    value: "Data point",
    numeric_value: "Data point",
    year_count: "Years",
    year: "Year"
  }.freeze

  def sort_columns
    case current_group
    when :company
      group_sort :company_name
    when :metric
      group_sort :metric_title
    when :record
      record_sort
    else
      simple_sort
    end
  end

  def sort_title key
    SORT_TITLES[key]
  end

  def record_sort
    {
      company_name: 4,
      metric_title: 4,
      value_field => 2,
      year: 2
    }
  end

  def simple_sort
    {
      company_name: 4,
      metric_title: 4,
      value_field => 2,
      year: 2
    }
  end

  def group_sort grouping
    { grouping => 8, answer_count: 2, year_count: 2 }
  end

  def value_field
    :value
  end

  def default_desc_sort_dir
    ::Set.new %i[updated_at metric_bookmarkers value year answer_count year_count]
  end

  # for override
  def secondary_sort_hash
    SECONDARY_SORT
  end

  def default_sort_option
    if current_group == :none
      default_ungrouped_sort_option
    else
      :answer_count
    end
  end

  def default_ungrouped_sort_option
    lookup? ? default_lookup_sort_option : :name
  end

  def default_lookup_sort_option
    :year
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

  private

  def valid_sort_options
    SORT_OPTIONS
  end
end
