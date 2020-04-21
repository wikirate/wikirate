
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

# DEPRECATED.  +answer csv replaces following:
format :csv do
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end

  CSV_COLUMNS = %i[
    question metric_type metric_designer metric_title wikirate_topic about
    methodology value_type value_options report_type research_policy
  ]

  CSV_COLUMN_TITLES = {
    metric_designer: "Metric Designer"
  }

  CSV_COLUMN_METHODS = {
    wikirate_topic: :semicolon_separated_values,
    report_type: :semicolon_separated_values,
    research_policy: :semicolon_separated_values,
    value_options: :semicolon_separated_values
  }

  view :csv_header do
    CSV_COLUMNS.map do |column|
      CSV_COLUMN_TITLES[column] || column.cardname
    end
  end

  view :csv_line do
    CSV_COLUMNS.map do |column|
      if (method = CSV_COLUMN_METHODS[column])
        send method, column
      else
        card.send column
      end
    end
  end

  private

  def semicolon_separated_values column
    card.send("#{column}_card").item_names.join ";"
  end
end
