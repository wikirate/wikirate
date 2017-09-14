# has to be called in finalize events so that in integrate stage all changes
# are collected in @updated_meteric_answers and can be executed
def refresh_answer_lookup_entry answer_id
  ActManager.act_card
            .act_based_refresh_of_answer_lookup_entry answer_id
end

def act_based_refresh_of_answer_lookup_entry answer_id
  @updated_answers ||= ::Set.new
  return if @updated_answers.include? answer_id
  Answer.find_by_answer_id answer_id
  @updated_answers << answer_id
end

event :refresh_updated_answers, :integrate, after_subcards: true do
  return unless @updated_answers
  Answer.refresh @updated_answers
end
