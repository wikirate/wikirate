
def answer
  @answer ||= Answer.existing(id) || Answer.new
end

event :update_answer_lookup_table_due_to_answer_change, :finalize, on: :update do
  if hybrid?
    update_answer id: answer.id
  else
    update_answer answer_id: id
  end
end
