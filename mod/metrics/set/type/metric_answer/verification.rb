def imported?
  answer.imported || false
end

# @return [Integer] current verification index
def verification
  if researched_value?
    checked_by_card&.verification || researched_verification
  elsif relationship?
    1 # hard-code unverified for now
  else
    calculated_verification
  end
end
alias :current_verification_index :verification

def researched_verification
  Answer.verification_index researched_verification_symbol
end

def researched_verification_symbol
  steward_added? ? :steward_added : :community_added
end

def steward_added?
  return true if metric_card.designer_assessed?

  answer.updater_id&.in? steward_ids
end

def steward_ids
  @steward_ids ||= Card::Set::Self::WikirateTeam.member_ids + metric_card.steward_ids
end

def update_related_verifications
  each_dependee_answer { |answer| answer.refresh :verification }
end

def update_verification
  answer.tap do |a|
    old_verification = a.verification
    a.refresh :verification
    update_related_verifications if a.verification != old_verification
  end
end

def each_dependee_answer
  metric_card.each_depender_metric do |metric|
    answer = Answer.where(metric_id: metric, company_id: company_id, year: year).take
    yield answer if answer.present?
  end
end

format :html do
  def flag_names
    super + %i[imported verification]
  end

  def verification_flag
    h = Answer::VERIFICATION_LEVELS[card.verification]
    return "" unless (icon = h[:icon])

    fa_icon icon, title: h[:title], class: "verification-#{h[:klass] || h[:name]}"
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
