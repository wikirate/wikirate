# has to be called in finalize events so that in integrate stage all changes
# are collected in @updated_metric_answers and can be executed
def update_answer id: nil, answer_id: nil, metric_id: nil
  ids = answer_ids_to_update id, answer_id, metric_id
  update_answers_now_or_later ids
end

def delete_answer answer_id:
   answer_id
end

def update_answers_now_or_later ids
  if act_finished_integrate_stage?
    Answer.update_by_ids ids
  else
    act_card.act_based_refresh_of_answer_lookup_entry ids
  end
end

def answer_ids_to_update id, answer_id, metric_id
  if metric_id
    Answer.where(metric_id: metric_id).pluck :id
  elsif answer_id
    Answer.where(answer_id: answer_id).pluck :id
  else
    [id]
  end
end

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
