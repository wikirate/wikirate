delegate :steward_ids, :steward?, to: :metric_card

# @return [Integer] current verification index
def verification
  if researched_value?
    checked_by_card&.verification || researched_verification
  elsif relation?
    1 # hard-code unverified for now
  else
    calculated_verification
  end
end
alias :current_verification_index :verification

def researched_verification
  ::Answer.verification_index researched_verification_symbol
end

def researched_verification_symbol
  steward_added? ? :steward_verified : :unverified
end

def calculated_verification
  direct_dependee_answers.map(&:verification).compact.min || 1
end

def steward_added?
  return true if metric_card.steward_assessed?

  answer.updater_id&.in? steward_ids
end

def update_related_verifications
  each_depender_answer { |answer| answer.refresh :verification }
end

def update_verification
  answer.tap do |a|
    old_verification = a.verification
    a.refresh :verification
    update_related_verifications if a.verification != old_verification
  end
end

format :html do
  def marker_names
    super + %i[verification]
  end

  def verification_hash
    ::Answer::VERIFICATION_LEVELS[(card.answer.verification || 1)]
  end

  def verification_marker
    h = verification_hash
    verification = h[:name]
    return "" unless basket[:icons][:material][verification]

    icon_tag verification, title: h[:title],
                           class: "verification-#{h[:klass] || verification}"
  end
end
