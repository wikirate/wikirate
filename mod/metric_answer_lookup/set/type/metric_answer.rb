# In theory the following shouldn't be necessary, because there is an event on the
# value card.

# event :update_answer_lookup_table_due_to_answer_deletion, :finalize, on: :delete do
#   delete_answer answer_id: id
# end
attr_writer :answer

event :update_answer_lookup_table_due_to_answer_change, :finalize, on: :update do
  if hybrid?
    update_answer id: answer.id
  else
    update_answer answer_id: id
  end
end

def answer
  @answer ||= Answer.existing(id) || virtual_answer || Answer.new
end

def virtual?
  new? && !answer.new_record?
end

def content
  virtual? ? answer.value : super
end

def updated_at
  virtual? ? answer.updated_at : super
end

def created_at
  virtual? ? answer.created_at : super
end

private

def virtual_answer
  return nil unless calculated?

  answer_by_metric_company_year
end

def answer_by_metric_company_year
  Answer.where(metric_id: metric_id, company_id: company_id, year: year.to_i).take
end
