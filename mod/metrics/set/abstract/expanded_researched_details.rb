format :html do
  def wrap_researched_details
    output [
      credit_details,
      yield,
      wrap_with(:div, _render_comments, class: "comments-div")
    ]
  end

  def credit_details
    nest(card.value_card, view: :credit)
  end

  view :expanded_researched_details do
    checked_by = card.fetch trait: :checked_by, new: {}
    checked_by = nest(checked_by, view: :core)
    wrap_researched_details do
      [
        wrap_with(:div, checked_by, class: "double-check mt-3"),
        wrap_with(:div, _render_sources, class: "cited-sources mt-3"),
        overridden_calculated_value
      ]
    end
  end

  def overridden_calculated_value
    return unless calculation_overridden?
    wrap_with :div, class: "mt-3 overridden-answer" do
      [
        wrap_with(:h5, "Overridden answer"),
        overridden_details
      ]
    end
  end

  def overridden_details
    case card.metric_type.to_sym
    when :formula
      overridden_formula_details
    when :descendant
      overridden_descendant_details
    else
      wrap_with :div, wrapped_overridden_value
    end
  end

  def overridden_formula_details
    wrap_with(:div,
              "#{humanized_overridden_calculated_value} = #{formula_details}",
              class: "formula-with-values")
  end

  def overridden_descendant_details
    wrap_with :div do
      [wrapped_overridden_value,
       render(:expanded_descendant_details, hide: :comments)]
    end
  end

  def wrapped_overridden_value
    <<-HTML
      <span class='metric-value'>
        #{card.answer.overridden_value}
      </span>
    HTML
  end

  def humanized_overridden_calculated_value
    <<-HTML
      <span class='metric-value'>
        #{humanized_number card.answer.overridden_value}
      </span>
    HTML
  end
end
