include_set Abstract::MetricChild, generation: 2
include_set Abstract::Record
include_set Abstract::Lookup

attr_writer :record

card_accessor :checked_by, type: :list
card_accessor :source, type: :list

event :delete_record_lookup, :finalize, on: :delete do
  ::Record.delete_for_card id
end

event :refresh_record_lookup, :finalize, on: :save do
  record.card = self
  record.refresh
end

def lookup_class
  ::Record
end

def lookup
  record
end

def record
  @record ||= ::Record.fetch self
end

def virtual?
  new? && (!record.new_record? || metric_card&.relation?)
end

def content
  virtual? ? record.value : super
end

def updated_at
  virtual? ? record.updated_at : super
end

def created_at
  virtual? ? record.created_at : super
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

def record_log_id
  left_id.positive? ? left_id : super
end

def checkers
  cb = checked_by_card
  cb.checkers.join ", " if cb&.checked?
end

def comments
  return unless (comment_card = fetch :discussion)

  comment_card.format(:text).render_core.gsub(/^\s*--.*$/, "").squish.truncate 1024
end

def overridden_value
  record.overridden_value
end
