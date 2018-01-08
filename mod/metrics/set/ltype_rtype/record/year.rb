include_set Type::MetricValue

def unknown?
  answer.blank?
end

def virtual?
  unknown? && answer.present?
end

# def new_card?
#   virtual? ? false : super
# end

def answer
  @answer ||= Answer.where(record_id: left.id, year: name.right.to_i).take
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

def type_id
  Card::MetricValueID
end
