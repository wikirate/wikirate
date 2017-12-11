format :html do
  def wrap_value_details
    output [
      _render(:credit_name),
      yield,
      wrap_with(:div, _render_comments, class: "comments-div")
    ]
  end

  view :researched_value_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_value_details do
      [
        wrap_with(:div, checked_by, class: "double-check"),
        wrap_with(:div, _render_sources, class: "cited-sources mt-3")
      ]
    end
  end
end
