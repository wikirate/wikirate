format :html do
  def marker_names
    super << :calculated
  end

  def calculated_marker
    if !card.calculated?
      ""
    elsif card.researched_value?
      overridden_marker_icon
    else
      calculated_marker_icon
    end
  end

  def calculated_marker_icon
    icon_tag :calculator, title: "Calculated answer", class: "text-success"
  end

  def overridden_marker_icon
    wrap_with :span, class: "overridden-icon", title: "Overridden calculated answer" do
      [icon_tag(:user), icon_tag(:calculator, class: "text-danger")]
    end
  end
end
