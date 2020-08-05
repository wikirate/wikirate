# name pattern: Metric+Subject Company+Year+Object Company

include_set Abstract::MetricChild, generation: 3
include_set Abstract::AnswerDetailsToggle
include_set Abstract::ExpandedResearchedDetails
include_set Abstract::MetricAnswer
include_set Abstract::DesignerPermissions

require_field :value
require_field :source, when: :source_required?

# has to happen after :set_answer_name,
# but always, also if :set_answer_name is not executed
event :schedule_answer_counts, :finalize do
  schedule_answer_count answer_name
  schedule_answer_count inverse_answer_name
end

event :schedule_old_answer_counts, :finalize, changed: :name, on: :update do
  lu = lookup
  schedule_answer_count lu.answer_id.cardname
  schedule_answer_count lu.inverse_answer_id.cardname
end

# TODO: this shouldn't be necessary if default type_id were based on ltype rtype set
event :ensure_left_type_is_answer, after: :prepare_left_and_right do
  answer = Card.fetch name.left, new: { type_id: MetricAnswerID }
  answer.type_id = MetricAnswerID
  add_subcard answer if answer.type_id_changed?
end

event :auto_add_object_company,
      after: :set_answer_name, on: :create, trigger: :required do
  add_company related_company unless valid_related_company?
end

def lookup
  ::Relationship.where(relationship_id: id).take
end

def related_company
  name.tag
end

def related_company_card
  Card[related_company]
end

def name_part_types
  %w[metric company year related_company]
end

def valid_related_company?
  (related_company_card&.type_id == Card::WikirateCompanyID) ||
    ActManager.include?(related_company)
end

def value_type_code
  metric_card.value_type_code
end

def value_cardtype_code
  metric_card.value_cardtype_code
end

def answer
  @answer ||= Card.fetch(answer_name)&.answer
end

def answer_id
  @answer_id ||= Card.fetch_id answer_name
end

def answer_name
  name.left
end

def inverse_answer_name
  [metric_card.inverse, related_company, year].join "+"
end

def inverse_answer_id
  @inverse_answer_id ||= Card.fetch_id inverse_answer_name
end

def schedule_answer_count name
  answer_card = Card.fetch name, new: { type_id: MetricAnswerID, "+value" => "1" }
  answer_card.try :schedule_answer_count
  add_subcard answer_card
end
