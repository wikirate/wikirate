def act_finished_integrate_stage?
  dir = act_card.director
  !dir.stage || dir.finished_stage?(:integrate)
end

def act_based_refresh_of_answer_lookup_entry ids
  @updated_answers ||= ::Set.new
  @updated_answers.merge ids
end

event :refresh_updated_answers, :integrate, after_subcards: true do
  return unless @updated_answers.present?
  Answer.update_by_ids @updated_answers
  @updated_answers = nil
end
