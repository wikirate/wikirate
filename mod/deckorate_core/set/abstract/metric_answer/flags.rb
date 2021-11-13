format :html do
  view :flags do
    flags
  end

  view :small_flags do
    flags.map { |flag| "<small>#{flag}</small>" }
  end

  def flag_names
    %i[comment calculated]
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
    # the following will work once relationships have answer lookups
    # return "" unless card.lookup&.comments&.present?
    # fa_icon :comment, title: "Has comments"
    field_nest :discussion, view: :flag
  end
end
