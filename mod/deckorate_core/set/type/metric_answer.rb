include_set Abstract::MetricChild, generation: 2
include_set Abstract::MetricAnswer
include_set Abstract::Lookup

attr_writer :answer

card_accessor :checked_by, type: :list
card_accessor :check_requested_by, type: :pointer
card_accessor :source, type: :list

event :delete_answer_lookup, :finalize, on: :delete do
  Answer.delete_for_card id
end

event :refresh_answer_lookup, :finalize, on: :save do
  answer.card = self
  answer.refresh
end

def lookup_class
  ::Answer
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
  cb.checkers.join ", " if cb&.checked?
end

def check_requester
  cb = checked_by_card
  cb.check_requester if cb&.check_requested?
end

def comments
  return unless (comment_card = field :discussion)

  comment_card.format(:text).render_core.gsub(/^\s*--.*$/, "").squish.truncate 1024
end

def overridden_value
  answer.overridden_value
end
