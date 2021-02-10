def imported?
  answer.imported || false
end

# @return [Integer] current verification index
def verification
  if metric_card.designer_assessed?
    Answer.verification_index :steward
  elsif researched_value?
    checked_by_card.verification
  elsif relationship?
    1 # hard-code unverified for now
  else
    calculated_verification
  end
end
alias :current_verification_index :verification

format :html do
  def flag_names
    super + %i[imported verification]
  end

  def verification_flag
    h = Answer::VERIFICATION_LEVELS[card.verification]
    icon = h[:icon] || "check-circle"
    fa_icon icon, class: "verification-#{h[:name]}", title: h[:title]
  end

  def verification_flag_for index

  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
