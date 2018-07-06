# This file is needed for handling virtual answers
include_set Type::MetricAnswer

def unknown?
  answer.blank?
end

def virtual?
  new_card? && answer.present?
end

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
  Card::MetricAnswerID
end

format :html do
  def show_menu_item_edit?
    card.metric_card.hybrid? || super()
  end
end
