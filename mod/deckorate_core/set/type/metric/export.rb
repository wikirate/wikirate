NESTED_FIELD_CODENAMES = %i[
  question metric_type about methodology value_type value_options report_type
  assessment unit range hybrid topic score formula rubric variables
].freeze

COUNT_FIELD_CODENAMES = %i[answer bookmarkers dataset company].freeze

FIELD_LABELS = {
  topic: :topics,
  score: :scores,
  answer: :answer,
  dataset: :datasets,
  company: :companies
}.freeze

format :json do
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
    hash[:answers_url] = path mark: card.answer_card, format: :json
  end

  def add_calculations_to_hash hash
    hash[:calculations] = card.direct_depender_metrics.map do |metric|
      path mark: metric, format: :json
    end
  end

  def add_count_fields_to_hash hash
    assign_each_field hash, COUNT_FIELD_CODENAMES do |fieldcode|
      card.fetch(fieldcode)&.cached_count
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
  COLUMN_METHODS = {
    topic: :semicolon_separated_values,
    report_type: :semicolon_separated_values,
    assessment: :semicolon_separated_values,
    value_options: :semicolon_separated_values
  }.freeze

  view :titled do # DEPRECATED.  +answer csv replaces this
    field_nest :answer, view: :titled
  end

  view :row do
    basic = cell_values(Abstract::MetricSearch::BASIC_COLUMNS)
            .unshift card_url(card.id_string)
    return basic unless detailed?

    basic + cell_values(Abstract::MetricSearch::DETAILED_COLUMNS)
  end

  private

  def cell_values columns
    columns.map { |key| cell_value key }
  end

  def cell_value key
    value = raw_cell_value key
    value.blank? ? nil : value
  end

  def raw_cell_value key
    method = COLUMN_METHODS[key]
    method ? send(method, key) : card.try(key)
  end

  def semicolon_separated_values column
    card.send("#{column}_card").item_names.join ";"
  end
end

format :jsonld do
  
  def molecule
    metric_jsonld(atom)
  end

  private

    def metric_jsonld(a)
    {
      "@context" => "#{request.base_url}/context/#{card.type}.jsonld",
      "@id"      => path(mark: card.name, format: nil),
      "@type"    => card.type,

      "title"    => a[:title] || a["title"],
      "designer" => "#{request.base_url}/#{a[:designer] || a["designer"]}",
      "question"  => a[:headquarters] || a["headquarters"],  

      "metric_type"                 => a[:metric_type] || a["metric_type"],
      "research_policy"             => a[:research_policy] || a["research_policy"],
      "about"                       => ActionView::Base.full_sanitizer.sanitize(a[:about] || a["about"]),
      "methodology"                 => ActionView::Base.full_sanitizer.sanitize(a[:methodology] || a["methodology"]),
      "topics"                      => get_topics(a[:topics] || a["topics"]),
      "calculations"                => get_elements(a[:calculations] || a["calculations"]),
      "variables"                   => get_variables,
      "report_type"                 => a[:report_type] || a["report_type"],
      "value_type"                 => a[:value_type] || a["value_type"],
      "value_options"               => get_elements(card.value_options),
      "value_range"                 => a[:value_range] || a["value_range"],
      "unit" => a[:unit] || a["unit"],
      "formula" => get_formula,
      "license" => license_url
    }.compact
  end

  def license_url
    dir = card.license.gsub(/(CC|4.0)/, "").strip.downcase
    "https://creativecommons.org/licenses/#{dir}/4.0/"
  end

  def get_variables
    variables = card.direct_dependee_metrics.map do |metric|
      path mark: metric, format: :json
    end
    variables&.any? ? variables : nil
  end

  def get_topics topics
    topics&.any? ? topics.map { |path| path(mark: path, format: nil) } : nil
  end

  def get_formula
    formula = card.formula
    formula.empty? ? nil : formula
  end

  def get_elements subcard
    subcard&.any? ? subcard : nil
  end
  
end
