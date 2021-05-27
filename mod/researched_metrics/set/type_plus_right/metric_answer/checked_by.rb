include_set Abstract::AnswerField

event :update_related_verifications, :after_integrate, skip: :allowed do
  answer_card.update_related_verifications
end
