include_set Abstract::Filterable

LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
           total: "Total" }.freeze

format do
  delegate :answer_query, :answer_lookup, to: :query

  def count_by_status
    @count_by_status ||= query.count_by_status
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

  def company_count
    @company_count ||= count_distinct :company_id
  end

  def metric_count
    @metric_count ||= single_metric? ? 1 : count_distinct(:metric_id)
  end

  def year_count
    @year_count ||= count_distinct :year
  end

  def count_distinct field
    answer_query.distinct.select(field).count
  end

  def record?
    false # TODO: detect records (single metric single company)
  end
end

format :html do
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

  def answer_count_badge count, codename
    simple_label = codename.cardname.vary :plural
    label = responsive_count_badge_label icon_tag: mapped_icon_tag(codename),
                                         simple_label: simple_label
    labeled_badge count, label, color: "#{codename.cardname.downcase} badge-secondary"
  end
end
