def imported?
  answer.imported || false
end

def checked?
  answer.checkers.present? || answer.check_requester.present?
end

def commented?
  disc = fetch trait: :discussion
  disc&.content.present?
end

format :html do
  view :flags, cache: :never do
    output [checked_value_flag, comment_flag, imported_flag, calculated_flag]
  end

  view :small_flags, cache: :never do
    output do
      [:checked_value, :comment, :imported].map do |flag_name|
        flag = send "#{flag_name}_flag"
        "<small>#{flag}</small>"
      end
    end
  end

  def calculated_flag
    return "" unless card.calculated?
    calculated_flag_icon
  end

  def calculated_flag_icon
    return overridden_flag_icon if card.calculation_overridden?
    fa_icon :calculator, title: "Calculated metric answer", class: "text-success"
  end

  def overridden_flag_icon
    title =  "Overridden calculated metric answer"
    wrap_with :span, class: "overridden-icon", title: title do
      [
        fa_icon(:user),
        fa_icon(:calculator, class: "text-danger")
      ]
    end
  end

  def checked_value_flag
    return "" unless card.checked?
    nest card.field(:checked_by), view: :icon
  end

  def comment_flag
    return "" unless card.commented?
    fa_icon :commenting, title: "Has comments"
  end

  def imported_flag
    return "" unless card.imported?
    icon_tag "upload", library: :font_awesome, title: "imported"
  end
end
