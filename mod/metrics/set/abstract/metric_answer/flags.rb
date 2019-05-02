def imported?
  answer.imported || false
end

format :html do
  view :flags do
    output flags
  end

  view :small_flags do
    output(flags.map { |flag| "<small>#{flag}</small>" })
  end

  def flags
    %i[checked_value comment imported calculated].map do |flag_name|
      send "#{flag_name}_flag"
    end
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

  def checked_value_flag
    flag_nest :checked_by
  end

  def comment_flag
    flag_nest :discussion
  end

  def flag_nest field
    field_nest field, view: :flag
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
