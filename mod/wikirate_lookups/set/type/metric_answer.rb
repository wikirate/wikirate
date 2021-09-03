include_set Abstract::Lookup

def lookup_class
  ::Answer
end

event :delete_answer_lookup, :finalize, on: :delete do
  Answer.delete_for_card id
end

attr_writer :answer

event :refresh_answer_lookup, :finalize, on: :save do
  answer.card = self
  answer.refresh
end

def lookup
  answer
end

def answer
  @answer ||= Answer.fetch self
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

def virtual_query
  return unless calculated?

  { metric_id: metric_id, company_id: company_id, year: year.to_i }
end
