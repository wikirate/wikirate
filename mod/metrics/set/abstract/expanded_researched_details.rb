format :html do
  def wrap_expanded_details
    output [
      nest(card.value_card, view: :credit),
      yield,
      wrap_with(:div, _render_comments, class: "comments-div")
    ]
  end

  view :expanded_researched_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_expanded_details do
      [
        wrap_with(:div, checked_by, class: "double-check mt-3"),
        wrap_with(:div, _render_sources, class: "cited-sources mt-3")
      ]
    end
  end
end
