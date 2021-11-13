include_set Abstract::Filterable

LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
           total: "Total" }.freeze

COUNT_FIELDS = {
  "answers.company_id": :wikirate_company,
  "answers.metric_id": :metric,
  "designer_id": :designer,
  "answers.verification": :verification,
  "metrics.metric_type_id": :metric_type,
  "metrics.value_type_id": :value_type,
  "answers.year": :year,
  "*": :metric_answer
}.freeze

format do
  delegate :lookup_query, :lookup_relation, to: :research_query

  def research_query
    answer_table_only do |research_query_hash|
      AnswerQuery.new research_query_hash, sort_hash, paging_params
    end
  end

  def research_count_query
    answer_table_only do |research_query_hash|
      AnswerQuery.new(research_query_hash).lookup_query
    end
  end

  def counts
    @counts ||= tally_counts
  end

  def tally_counts
    counts = answer_table_counts
    researched = counts[:metric_answer].to_i
    total = all_answer? ? count_query.count : researched

    counts.merge(knowns_and_unknowns(researched)).merge(
      metric_answer: total, researched: researched, none: (total - researched)
    )
  end

  def answer_table_counts
    return {} if not_researched?

    research_count_query.joins(:metric).pluck_all(*count_fields).first.symbolize_keys
  end

  def count_fields
    COUNT_FIELDS.map do |field, key|
      field = "DISTINCT(#{field})" unless field.to_s == "*"
      "COUNT(#{field}) AS #{key}"
    end
  end

  def knowns_and_unknowns researched
    unknowns = research_count_query.where("answers.value = 'Unknown'").count
    { unknown: unknowns, known: (researched - unknowns) }
  end

  def all_answer?
    status_filter.in? %i[all none]
  end

  def not_researched?
    status_filter == :none
  end

  def status_filter
    filter_hash[:status]&.to_sym
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

  private

  def answer_table_only
    @answer_table_only = true

    yield query_hash.merge(answer_table_only_alteration)
  end

  def answer_table_only_alteration
    case status_filter
    when :all
      { status: :exists }
    when :none
      # the combination of :none status and a "Researched Only" field (value)
      # ensures an empty result
      { value: "bogus" }
    else
      {}
    end
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
    labeled_badge number_with_delimiter(count),
                  answer_count_badge_label(codename, count),
                  color: "#{codename.cardname.downcase} badge-secondary"
  end

  def answer_count_badge_label codename, count
    simple_label = codename.cardname.pluralize count
    responsive_count_badge_label icon_tag: mapped_icon_tag(codename),
                                 simple_label: simple_label
  end

  def show_chart?
    voo.show?(:chart) && !not_researched? && counts[:researched] > 1
  end
end
