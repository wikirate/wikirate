
format :json do
  NESTED_FIELD_CODENAMES =
    %i[question metric_type about methodology value_type value_options
       report_type research_policy unit range hybrid
       wikirate_topic score].freeze

  NESTED_FIELD_LABELS = {
    wikirate_topic: :topics,
    score: :scores
  }
  #metric_answer].freeze

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
    add_standard_nested_fields_to_hash hash, view
    answer = card.metric_answer_card
    hash[:answers] = answer.cached_count
    hash[:answers_url] = path mark: answer, format: :json
    hash
  end

  def add_standard_nested_fields_to_hash hash, view=:atom
    NESTED_FIELD_CODENAMES.each do |fieldcode|
      label = NESTED_FIELD_LABELS[fieldcode] || fieldcode
      hash[label] = field_nest fieldcode, view: view
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
    # , write_empty_value: nil (not supported until recently)
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
