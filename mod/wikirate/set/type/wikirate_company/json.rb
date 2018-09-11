format :json do
  NESTED_FIELD_CODENAMES = %i[wikipedia open_corporates aliases headquarters].freeze

  view :fields do
    NESTED_FIELD_CODENAMES.each_with_object({}) do |field_name, h|
      h[field_name] = field_nest field_name
    end
  end

  view :links do
    []
  end

  view :atom do
    hash = super().merge records_url: path(mark: card.field(:record), format: :json)
    hash.delete(:content)
    hash
  end

  view :molecule do
    super().merge fields: _render_fields
  end
end
