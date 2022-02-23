include_set Set::Abstract::Calculation

delegate :categorical?, :value_options, :value_option_names, to: :scoree_card
delegate :calculator_class, to: :formula_card

event :validate_score_name, :validate, changed: :name, on: :save do
  unless scoree_card&.type_id == MetricID
    errors.add :name, "#{scoree} is not a metric"
  end
  # can't be company because Metric+Company is a record
  unless scorer_card&.type_id.in? [UserID, ResearchGroupID]
    errors.add :name, "Invalid Scorer: #{scorer}; must be a User or Research Group"
  end
end

event :set_scored_metric_name, :initialize, on: :create do
  return if name.parts.size >= 3
  metric = drop_field(:metric)&.first_name
  self.name = "#{metric}+#{Auth.current.name}"
end

# event :default_formula, :prepare_to_store, on: :create, when: :formula_unspecified? do
#   subfield :formula, content: "answer", type_id: PlainTextID
# end

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

def base_input_array
  input = { metric: left_id, name: "answer" }
  input[:unknown] = "Unknown" if categorical?
  [input]
end

def calculator_class
  categorical? ? Calculate::Rubric : Calculate::JavaScript
end

def formula
  categorical? ? rubric_card.translation_hash : super
end

# </OVERRIDES>

def scorer
  name.tag
end

def scorer_id
  name.tag_name.card_id
end

def scorer_card
  right
end

def scoree
  name.trunk
end

def scoree_card
  left
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

def direct_dependee_metrics
  [left]
end

# def formula_unspecified?
#   !subfield(:formula)&.content&.present?
# end

format :html do
  view :formula do
    if card.categorical?
      field_nest :rubric, view: :titled, title: "Formula"
    else
      field_nest :formula, view: :titled
    end
  end
end
