format :json do
  NESTED_FIELD_CODENAMES = %i[
    question metric_type about methodology value_type value_options report_type
    research_policy unit range hybrid wikirate_topic score formula
  ].freeze

  COUNT_FIELD_CODENAMES =
    %i[metric_answer bookmarkers dataset wikirate_company].freeze

  FIELD_LABELS = {
    wikirate_topic: :topics,
    score: :scores,
    metric_answer: :answers,
    dataset: :datasets,
    wikirate_company: :companies
  }.freeze

  view :links do
    []
  end

  def atom
    hash = super().merge designer: card.metric_designer, title: card.metric_title
    add_fields_to_hash hash, :core
    hash
  end

  def molecule
    super.merge add_fields_to_hash({})
  end

  private

  def add_fields_to_hash hash, view=:atom
    add_nested_fields_to_hash hash, view
    add_count_fields_to_hash hash
    add_calculations_to_hash hash
    add_answers_to_hash hash
    hash
  end

  def add_answers_to_hash hash
    hash[:answers_url] = path mark: card.metric_answer_card, format: :json
  end

  def add_calculations_to_hash hash
    hash[:calculations] = card.direct_depender_metrics.map do |metric|
      path mark: metric, format: :json
    end
  end

  def add_count_fields_to_hash hash
    assign_each_field hash, COUNT_FIELD_CODENAMES do |fieldcode|
      card.field(fieldcode)&.cached_count
    end
  end

  def add_nested_fields_to_hash hash, view=:atom
    assign_each_field hash, NESTED_FIELD_CODENAMES do |fieldcode|
      field_nest fieldcode, view: view
    end
  end

  def assign_each_field hash, list
    list.each do |fieldcode|
      label = FIELD_LABELS[fieldcode] || fieldcode
      hash[label] = yield fieldcode
    end
  end
end

format :csv do
  view :core do # DEPRECATED.  +answer csv replaces this
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end

  COLUMN_METHODS = {
    wikirate_topic: :semicolon_separated_values,
    report_type: :semicolon_separated_values,
    research_policy: :semicolon_separated_values,
    value_options: :semicolon_separated_values
  }.freeze

  view :header do
    CSV.generate_line MetricImportItem.headers
  end

  view :line do
    CSV.generate_line(line_values.map { |v| v.blank? ? nil : v })
    # , write_empty_value: nil (only supported in recent versions)
  end

  private

  def line_values
    MetricImportItem.column_keys.map do |column|
      method = COLUMN_METHODS[column]
      method ? send(method, column) : card.try(column)
    end
  end

  def semicolon_separated_values column
    card.send("#{column}_card").item_names.join ";"
  end
end
