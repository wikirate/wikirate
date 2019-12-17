include_set Abstract::Filterable

format :html do
  # view :stats, cache: :never do
  #   table stat_rows,
  #         class: "filtered-answer-counts table-sm table-borderless text-muted"
  # end

  LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
             total: "Total" }.freeze

  def count_by_status
    @count_by_status ||= card.query.count_by_status
  end

  def stati_with_counts skip_total=false
    LABELS.keys.reject do |status|
      (skip_total && status == :total) || !count_by_status.key?(status)
    end
  end

  def map_status skip_total=false
    stati_with_counts(skip_total).map do |status|
      yield status, count_by_status[status]
    end
  end

  def total_results
    @total_results = count_by_status[:total] || count_by_status.values.first
  end

  def total_row?
    count_by_status.key? :total
  end

  def operand cat
    case cat
    when :known then ""
    when :total then "="
    else             "+"
    end
  end

  view :progress_bar, cache: :never do
    sections = map_status(true) do |status, count|
      { value: (count / total_results.to_f * 100),
        body: "#{count} #{LABELS[status]}",
        title: "#{count} #{LABELS[status]} Answers",
        class: "_filter-link progress-#{status}",
        data: { filter: { status: status } } }
    end
    progress_bar(*sections)
  end
end
