
format :html do
  view :flags do
    flags
  end

  view :small_flags do
    flags.map { |flag| "<small>#{flag}</small>" }
  end

  def flag_names
    %i[comment imported calculated]
  end

  def flags
    flag_names.map { |flag_name| send "#{flag_name}_flag" }
  end

  def calculated_flag
    if !card.calculated?
      ""
    elsif card.researched_value?
      overridden_flag_icon
    else
      calculated_flag_icon
    end
  end

  def calculated_flag_icon
    fa_icon :calculator, title: "Calculated answer", class: "text-success"
  end

  def overridden_flag_icon
    wrap_with :span, class: "overridden-icon", title: "Overridden calculated answer" do
      [fa_icon(:user), fa_icon(:calculator, class: "text-danger")]
    end
  end

  def comment_flag
    return "" unless card.answer&.comment&.present?

    fa_icon :commenting, title: "Has comments"
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
