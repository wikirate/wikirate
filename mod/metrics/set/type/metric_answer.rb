include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer

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
  return unless (comment_card = discussion_card)

  comment_card.format(:text).render_core.gsub(/^\s*--.*$/, "").squish.truncate 1024
end

def overridden_value
  super.tap { |ov| return unless ov.present? }
end
