format :json do
  NESTED_FIELD_CODENAMES = %i[wikipedia open_corporates aliases headquarters].freeze

  view :fields do
    add_fields_to_hash({})
  end

  view :links do
    []
  end

  view :items do
    []
  end

  view :atom do
    hash = super().merge records_url: path(mark: card.field(:record), format: :json)
    hash.delete(:content)
    add_fields_to_hash hash, :core
    hash
  end

  view :molecule do
    super().merge _render_fields
  end

  def add_fields_to_hash hash, view=:atom
    NESTED_FIELD_CODENAMES.each do |fieldcode|
      hash[fieldcode] = field_nest fieldcode, view: view
    end
    hash
  end
end
