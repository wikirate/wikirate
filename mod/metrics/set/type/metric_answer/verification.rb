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
    %i[verification imported] + super
  end

  def verification_flag
    verification_flag_for card.verification
  end

  def verification_flag_for index
    h = Answer::VERIFICATION_LEVELS[index]
    icon = h[:icon] || "check-circle"
    fa_icon icon, class: "verify-#{h[:color]}", title: h[:title]
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
