include_set Abstract::Filterable

LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
           total: "Total" }.freeze

DISTINCTS = {
  company_id: :wikirate_company,
  metric_id: :metric,
  designer_id: :designer,
  metric_type_id: :metric_types,
  year: :year
}

INDISTINCTS = {
  "value <> 'Unknown'" => :known,
  "value = 'Unknown'" => :unknown,
  "*" => :metric_answer
}

format do
  delegate :answer_query, :answer_lookup, to: :query

  def counts
    @counts ||= answer_table_counts.merge(unresearched_counts)
  end

  def answer_table_counts
    return {} if status_filter == :none

    fields = distinct_fields + indistinct_fields
    count_query.answer_query.pluck_all(*fields).first.symbolize_keys
  end

  def unresearched_counts
    return {} unless unresearched_query?
    researched = counts[:metric_answer].to_i
    total = count_query.count

    { metric_answer: total, none: (total - researched) }
  end

  def distinct_fields
    count_fields(DISTINCTS) { |field| "DISTINCT(#{field})" }
  end

  def indistinct_fields
    count_fields INDISTINCTS
  end

  def count_fields fields
    fields.map do |field, key|
      "COUNT(#{block_given? ? yield(field) : field}) AS #{key}"
    end
  end

  def unresearched_query?
    status_filter.in? %i[all none]
  end

  def status_filter
    filter_hash[:status]
  end

  def total_results
    counts[:metric_answer]
  end

  def single? field
    counts[field] == 1
  end

  def record?
    single?(:metric) && single?(:wikirate_company)
  end
end

format :html do
  def each_progress_bar_status
    %i[known unknown none].map do |status|
      yield status, counts[status] if counts[status].to_i > 0
    end.compact
  end

  view :progress_bar, cache: :never do
    sections = each_progress_bar_status do |status, count|
      { value: (count / total_results.to_f * 100),
        body: "#{count} #{LABELS[status]}",
        title: "#{count} #{LABELS[status]} Answers",
        class: "_filter-link progress-#{status}",
        data: { filter: { status: status } } }
    end
    progress_bar(*sections)
  end

  def answer_count_badge codename
    count = counts[codename]
    simple_label = codename.cardname.pluralize count
    label = responsive_count_badge_label icon_tag: mapped_icon_tag(codename),
                                         simple_label: simple_label
    labeled_badge count, label, color: "#{codename.cardname.downcase} badge-secondary"
  end
end
