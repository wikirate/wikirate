include_set Abstract::Lookup

def lookup_class
  ::Answer
end

event :delete_answer_lookup, :finalize, on: :delete do
  Answer.delete_for_card id
end

attr_writer :answer

event :refresh_answer_lookup, :finalize, on: :save do
  answer.refresh
end

def lookup
  answer
end

def answer
  @answer ||= Answer.existing(id) || virtual_answer || Answer.new
end

def virtual?
  new? && (!answer.new_record? || metric_card&.relationship?)
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
