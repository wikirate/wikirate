LABELS = { known: "Known", unknown: "Unknown", none: "Not Researched",
           total: "Total" }.freeze

COUNT_FIELDS = {
  "answers.company_id": :company,
  "answers.metric_id": :metric,
  "answers.year": :year,
  "answers.id": :answer
}.freeze

DEEP_COUNT_FIELDS = {
  "designer_id": :designer,
  "metrics.metric_type_id": :metric_type,
  "metrics.value_type_id": :value_type,
  "answers.verification": :verification,
  "answers.route": :route
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
    researched = counts[:answer].to_i
    total = all_answer? ? count_query.count : researched

    counts.merge(knowns_and_unknowns(researched)).merge(
      answer: total, researched: researched, none: (total - researched)
    )
  end

  def deep_counts
    @deep_counts ||= tally_deep_counts
  end

  def tally_deep_counts
    fields = COUNT_FIELDS.merge DEEP_COUNT_FIELDS
    research_count_query.joins(:metric)
                        .pluck_all(*count_fields(fields))
                        .first
                        .symbolize_keys
  end

  def answer_table_counts
    return {} if not_researched?

    research_count_query.pluck_all(*count_fields(COUNT_FIELDS)).first.symbolize_keys
  end

  def count_fields fields
    fields.map do |field, key|
      "COUNT(DISTINCT(#{field})) AS #{key}"
    end
  end

  def knowns_and_unknowns researched
    unknowns = researched.zero? ? 0 : count_unknowns
    { unknown: unknowns, known: (researched - unknowns) }
  end

  def count_unknowns
    research_count_query.where("answers.value = 'Unknown'").count
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
    counts[:answer]
  end

  def no_results?
    total_results.zero?
  end

  def single? field
    counts[field] == 1
  end

  # def record?
  #   single?(:metric) && single?(:company)
  # end

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
  def count_badge_label
    badge_label :answer
  end

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
        class: "_compact-filter-link progress-#{status}",
        data: { filter: { status: status } } }
    end
    progress_bar(*sections)
  end

  def badge_label codename
    return "Data points".to_name if codename == :answer

    Codename.exist?(codename) ? codename.cardname : codename.to_s.to_name
  end

  def answer_count_badge codename, count=nil
    count ||= counts[codename]
    labeled_badge number_with_delimiter(count),
                  answer_count_badge_label(codename, count),
                  color: "light"
  end

  def answer_count_badge_label codename, count
    simple_label = badge_label(codename).vary("capitalize").pluralize count
    if (icon = icon_tag codename)
      responsive_count_badge_label icon_tag: icon, simple_label: simple_label
    else
      simple_label
    end
  end

  def show_chart?
    voo.show?(:chart) && !not_researched? && counts[:researched] > 1
  end
end
