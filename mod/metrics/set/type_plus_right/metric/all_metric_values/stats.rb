format :html do
  view :stats do
    table rows(filter_hash[:metric_value] || :exists),
          class: "filtered-answer-counts table-sm table-borderless text-muted"
  end

  CATEGORIES = { all: [:known, :unknown, :none],
                 exists: [:known, :unknown] }.freeze

  LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
             total: "Total results" }

  def rows category
    category = category.to_sym
    rows = CATEGORIES[category] || [category]
    with_total = rows.size >= 2
    rows << :total if with_total
    rows.map { |cat| row_cells cat, with_total }
  end

  def row_cells cat, with_total
    cat = cat.to_sym
    cells = with_total ? [operand(cat)] : []
    cells << badge_tag(category_count(cat), class: cat)
    cells << LABELS[cat]
    { content: cells, class: cat }
  end

  def operand cat
    case cat
    when :known then  ""
    when :total then "="
    else             "+"
    end
  end

  def category_count cat
    return @total if cat == :total
    @total ||= 0
    count = card.query.count metric_value: cat
    @total += count
    count
  end
end
