include_set Abstract::Filterable

LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
           total: "Total" }.freeze

COUNT_FIELDS = {
  company_id: :wikirate_company,
  "answers.metric_id": :metric,
  "designer_id": :designer,
  "metrics.metric_type_id": :metric_types,
  year: :year,
  "*": :metric_answer
}.freeze

format do
  delegate :answer_query, :answer_lookup, to: :query

  def counts
    @counts ||= tally_counts
  end

  def tally_counts
    counts = answer_table_counts
    researched = counts[:metric_answer].to_i
    total = unresearched_query? ? count_query.count : researched

    counts.merge(knowns_and_unknowns(researched)).merge(
      metric_answer: total, researched: researched, none: (total - researched)
    )
  end

  def answer_table_counts
    return {} if status_filter == :none

    count_query.answer_query.joins(:metric).pluck_all(*count_fields).first.symbolize_keys
  end

  def count_fields
    COUNT_FIELDS.map do |field, key|
      field = "DISTINCT(#{field})" unless field.to_s == "*"
      "COUNT(#{field}) AS #{key}"
    end
  end

  def knowns_and_unknowns researched
    unknowns = count_query.answer_query.where("value = 'Unknown'").count
    { unknown: unknowns, known: (researched - unknowns) }
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
      yield status, counts[status] if counts[status].to_i.positive?
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

  def show_chart?
    super && counts[:researched] > 1
  end
end
