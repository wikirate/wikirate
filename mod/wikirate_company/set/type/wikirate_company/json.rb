format :json do
  NESTED_FIELD_CODENAMES = %i[wikipedia open_corporates aliases headquarters].freeze

  view :links do
    []
  end

  view :items do
    []
  end

  view :atom do
    hash = super()
    hash.delete(:content)
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
