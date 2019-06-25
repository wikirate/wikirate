format :html do
  view :stats, cache: :never do
    table stat_rows, class: "filtered-answer-counts table-sm table-borderless text-muted"
  end

  LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
             total: "Total" }.freeze

  def stat_rows
    rows = card.query.count_by_status
    more_than_one = rows.keys.size > 1
    LABELS.keys.map do |status|
      next unless count = rows[status]
      stat_row status, count, more_than_one
    end.compact
  end

  def stat_row cat, count, more_than_one
    cat = cat.to_sym
    cells = more_than_one ? [{ content: operand(cat), class: "text-right" }] : []
    cells << { content: badge_tag(count, class: cat), class: "text-right" }
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
end
