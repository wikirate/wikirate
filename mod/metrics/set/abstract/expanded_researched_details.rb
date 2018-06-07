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
        overridden_calculated_value,
        wrap_with(:div, checked_by, class: "double-check mt-3"),
        wrap_with(:div, _render_sources, class: "cited-sources mt-3")
      ]
    end
  end

  def overridden_calculated_value
    return unless calculation_overridden?
    wrap_with :div, class: "mt-3" do
      [
        wrap_with(:h5, "Calculated answer"),
        wrap_with(:div,
                  "#{render_overridden_calculated_value} = #{formula_details}",
                  class: "formula-with-values")
      ]
    end
  end

  view :overridden_calculated_value do
    <<-HTML
      <span class='metric-value'>
        #{humanized_number card.answer.calculated_value}
      </span>
    HTML
  end
end
