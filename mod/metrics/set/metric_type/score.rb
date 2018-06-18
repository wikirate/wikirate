include Set::Abstract::Calculation

# <OVERRIDES>
def score?
  true
end

def ten_scale?
  true
end

def needs_name?
  false
end

def formula_editor
  categorical? ? :categorical_editor : super
end

def formula_core
  categorical? ? :categorical_core : super
end
# </OVERRIDES>

def scorer
  name.tag
end

def scorer_card
  right
end

def basic_metric
  name.trunk
end

def basic_metric_card
  left
end

def categorical?
  basic_metric_card.categorical?
end

def normalize_value value
  return value if value.is_a? String
  return "0" if value.negative?
  return "10" if value > 10
  value.to_s
end

def value_type
  "Number"
end

def value_options
  basic_metric_card.value_options
end

event :validate_score_name, :validate, changed: :name, on: :save do
  return if basic_metric_card&.type_id == MetricID
  errors.add :name, "#{basic_metric} is not a metric"
end

event :set_scored_metric_name, :initialize,
      on: :create do
  return if name.parts.size >= 3
  metric = (mcard = remove_subfield(:metric)) && mcard.item_names.first
  self.name = "#{metric}+#{Auth.current.name}"
end

event :default_formula, :prepare_to_store,
      on: :create,
      when:  proc { |c| !c.subfield_formula_present?  } do
  add_subfield :formula, content: "{{#{basic_metric}}}",
                         type_id: PlainTextID
end

def subfield_formula_present?
  (f = subfield(:formula)) && f.content.present?
end
