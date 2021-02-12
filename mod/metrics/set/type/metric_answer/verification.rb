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
  answer.editor_id&.in? steward_ids
end

def steward_ids
  @steward_ids ||=
    Card::Set::Self::WikirateTeam.member_ids << metric_card.metric_designer_id
end

def update_related_verifications
  each_dependee_answer { |answer| answer.refresh :verification }
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
    icon = h[:icon] || "check-circle"
    fa_icon icon, class: "verification-#{h[:name]}", title: h[:title]
  end

  def imported_flag
    card.imported? ? icon_tag("upload", library: :font_awesome, title: "imported") : ""
  end
end
