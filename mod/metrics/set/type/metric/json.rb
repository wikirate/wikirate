format :json do
  NESTED_FIELD_CODENAMES =
    %i[metric_type about methodology value_type value_options
       report_type research_policy project unit
       range currency hybrid question score].freeze

  view :fields do
    NESTED_FIELD_CODENAMES.each_with_object({}) do |field_name, h|
      h[field_name] = field_nest field_name
    end
  end

  view :links do
    []
  end

  view :atom do
    super().merge records_url: path(mark: card.field(:record), format: :json)
  end

  view :molecule do
    super().merge fields: _render_fields
  end
end
