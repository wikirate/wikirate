
format :json do
  NESTED_FIELD_CODENAMES =
    %i[metric_type about methodology value_type value_options
       report_type research_policy project unit
       range hybrid question score].freeze

  view :links do
    []
  end

  view :atom do
    hash = super().merge designer: card.metric_designer, title: card.metric_title
    add_fields_to_hash hash, :core
    hash
  end

  view :molecule do
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
  view :core do
    Answer.csv_title + Answer.where(metric_id: card.id).map(&:csv_line).join
  end
end
