
format :json do
  NESTED_FIELD_CODENAMES =
    %i[metric_type about methodology value_type value_options
       report_type research_policy unit
       range hybrid question score].freeze

  view :links do
    []
  end

  def atom
    hash = super().merge designer: card.metric_designer, title: card.metric_title
    add_fields_to_hash hash, :core
    hash
  end

  def molecule
    super().merge(add_fields_to_hash({}))
           .merge answers_url: path(mark: card.field(:metric_answer), format: :json)
  end

  def add_fields_to_hash hash, view=:atom
    NESTED_FIELD_CODENAMES.each do |fieldcode|
      hash[fieldcode] = field_nest fieldcode, view: view
    end
    hash
  end
end

format :csv do
# DEPRECATED.  +answer csv replaces following:
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end

  COLUMNS = %i[
    question metric_type metric_designer metric_title wikirate_topic about
    methodology value_type value_options report_type research_policy
  ]

  COLUMN_TITLES = {
    metric_designer: "Metric Designer",
    scorer: "Scorer"
  }

  COLUMN_METHODS = {
    wikirate_topic: :semicolon_separated_values,
    report_type: :semicolon_separated_values,
    research_policy: :semicolon_separated_values,
    value_options: :semicolon_separated_values
  }

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
