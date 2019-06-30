format :html do
  view :stats, cache: :never do
    table stat_rows, class: "filtered-answer-counts table-sm table-borderless text-muted"
  end

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

  def stat_rows
    map_status { |status, count| stat_row status, count }
  end

  def stat_row cat, count
    cat = cat.to_sym
    cells = multicount? ? [{ content: operand(cat), class: "text-right" }] : []
    cells << { content: badge_tag(count, class: cat), class: "text-right" }
    cells << LABELS[cat]
    { content: cells, class: cat }
  end

  def total_results
    @total_results = count_by_status[:total] || count_by_status.values.first
  end

  def multicount?
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
        body: count,
        title: "#{count} #{LABELS[status]} Answers",
        class: "progress-#{status}" }
    end
    progress_bar(*sections)
  end
end
