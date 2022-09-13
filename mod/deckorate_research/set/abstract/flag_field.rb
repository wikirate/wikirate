event :related_verifications_after_flagging, :integrate, skip: :allowed do
  flag_card.subject_card.first_card.update_related_verifications
end
