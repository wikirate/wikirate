event :related_verifications_after_flagging, :integrate, skip: :allowed do
  flag_card.subject_card.first_card.update_related_verifications
end

event :remove_confirmation, :validate, on: :save do
  return if flag_card.status == "closed"

  checked_by = lookup_card.checked_by_card
  return unless checked_by&.count&.positive?

  checked_by.content = ""
  subcards.add checked_by
end
