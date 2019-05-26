format :html do
  view :stats, cache: :never do
    table stat_rows(filter_hash[:status] || :exists),
          class: "filtered-answer-counts table-sm table-borderless text-muted"
  end

  CATEGORIES = { all: [:known, :unknown, :none, :total],
                 exists: [:known, :unknown, :total] }.freeze

  LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
             total: "Total results" }.freeze

  def stat_rows category
    @total = 0
    category = category.to_sym
    rows = CATEGORIES[category] || [category]

    rows.map { |cat| row_cells(cat, rows.size > 2) }
  end

  def row_cells cat, more_than_one
    cat = cat.to_sym
    cells = more_than_one ? [{ content: operand(cat), class: "text-right" }] : []
    cells << { content: badge_tag(category_count(cat), class: cat),
               class: "text-right" }
    cells << LABELS[cat]
    { content: cells, class: cat }
  end

  def operand cat
    case cat
    when :known then ""
    when :total then "="
    else             "+"
    end
  end

  def category_count cat
    return @total if cat == :total
    @total ||= 0
    count = card.query.count status: cat
    @total += count
    count
  end
end
