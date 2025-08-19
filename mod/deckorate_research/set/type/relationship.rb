# name pattern: Metric+Subject Company+Year+Object Company

include_set Abstract::MetricChild, generation: 3
include_set Abstract::Answer
include_set Abstract::StewardPermissions
include_set Abstract::Lookup
include_set Abstract::LookupEvents

card_accessor :checked_by, type: :list
card_accessor :source, type: :list

require_field :value
require_field :source, when: :source_required?

delegate :inverse_metric_id, :subject_company_id, :object_company_id, to: :lookup
delegate :relationship_id, to: :lookup

event :ensure_simple_answers, after: :prepare_left_and_right, on: :save do
  [answer_card, inverse_answer_card].each do |card|
    # TODO: this shouldn't be necessary.
    # default type_id should be based on ltype rtype set
    # (but good to make sure the simple cards are there regardless)
    card.type_id = AnswerID
    subcard card if card.type_id_changed?
  end
end

event :schedule_answer_counts, :integrate do
  answer_card.schedule :update_relationship_count
  inverse_answer_card.schedule :update_relationship_count
end

event :schedule_old_answer_counts, :finalize, changed: :name, on: :update do
  lu = lookup
  [lu.answer_id, lu.inverse_answer_id].each do |id|
    id.card.schedule :update_relationship_count
  end
end

event :auto_add_object_company,
      after: :set_answer_name, on: :create, trigger: :required do
  add_company related_company unless valid_related_company?
end

def lookup_class
  ::Relationship
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
  (related_company_card&.type_id == Card::CompanyID) ||
    Director.include?(related_company)
end

def numeric_value
  ::Answer.to_numeric value if metric_card.numeric?
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
  @answer_id ||= left_id.positive? ? left_id : answer_name.card_id
end

def answer_name
  name.left_name
end

def answer_card
  answer_card_fetch answer_name
end

def inverse_answer_name
  [metric_card.inverse, related_company, year].cardname
end

def inverse_answer_card
  answer_card_fetch inverse_answer_name
end

def answer_card_fetch name
  Card.fetch name, new: { type: :answer, fields: { value: "1" } }
end

def inverse_answer_id
  @inverse_answer_id ||= inverse_answer_name.card_id
end

def update_subcard_name subcard, new_name, name_to_replace
  name_to_replace = subcard.name.left if subcard.name.match?(/\+\+/)
  super
end

def source_required?
  true
end

def steward?
  false
end
