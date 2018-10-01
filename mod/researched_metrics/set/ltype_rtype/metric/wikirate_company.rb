include_set Abstract::WikirateTable # deprecated, but not clear if it is still used
include_set Abstract::MetricChild, generation: 1
include_set Abstract::Table

event :set_record_type, :prepare_to_store, on: :create do
  self.type_id = RecordID
end

def latest_value_year
  Answer.latest_year metric_card.id, company_card.id
end

def latest_value_card
  Answer.latest_answer_card metric_card.id, company_card.id
end

def virtual?
  true
end
