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

  def sort_options
    {
      "Year": :year,
      "Company": :company_name,
      "Metric": :metric_title,
      "Answer": :value
    }
  end

  def default_sort_dir sort_by
    return super unless sort_by == :value

    :default_value_sort_dir
  end

  def default_desc_sort_dir
    ::Set.new %i[updated_at metric_bookmarkers value year]
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
