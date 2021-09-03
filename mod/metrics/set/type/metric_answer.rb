include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

# this is a bit of a hack.
# Since we don't add renamed children to the act any more, we
# have to trigger the value validation manually
event :run_value_events_on_name_change, :validate, changed: :name, on: :update do
  value_card = Card[name_before_act, :value]
  value_card.instance_variable_set "@name", Card::Name[name, :value]
  value_card.valid?
  value_card.errors.each do |error|
    errors.add :value, error.message
  end
end

def value_type_code
  metric_card.simple_value_type_code
end

def value_cardtype_code
  metric_card.simple_value_cardtype_code
end

# FOR LOOKUP
# ~~~~~~~~~~

def record_id
  left_id.positive? ? left_id : super
end

def checkers
  cb = checked_by_card
  return unless cb&.checked?

  cb.checkers.join ", "
end

def check_requester
  cb = checked_by_card
  return unless cb&.check_requested?

  cb.check_requester
end

def comments
  return unless (comment_card = field :discussion)

  comment_card.format(:text).render_core.gsub(/^\s*--.*$/, "").squish.truncate 1024
end

def overridden_value
  answer.overridden_value
end
