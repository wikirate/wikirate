format :html do
  def wrap_researched_details
    output [credit_details, yield, render_comments]
  end

  def credit_details
    nest(card.value_card, view: :credit) unless card.new?
  end

  view :expanded_researched_details do
    wrap_researched_details do
      [render_sources, checked_by_details, override_details]
    end
  end

  def checked_by_details
    return if metric_card.designer_assessed?

    nest card.fetch(:checked_by, new: {}), view: :titled, title: "Checks"
  end

  def override_details
    return unless calculation_overridden?
    wrap_with :div, class: "mt-3 overridden-answer" do
      [wrap_with(:h5, "Overridden answer"),
       overridden_answer]
    end
  end

  def overridden_answer
    case card.metric_type.to_sym
    when :formula
      overridden_formula
    when :descendant
      overridden_descendant
    else
      wrap_with :div, wrapped_overridden_value
    end
  end

  def overridden_formula
    wrap_with(:div,
              "#{humanized_overridden_calculated_value} = #{formula_details}",
              class: "formula-with-values")
  end

  def overridden_descendant
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
