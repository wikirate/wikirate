# NOTE: it would be nice to have these accessors in Abstract::Calculation, but
# if there they don't properly set the default cardtype for the fields

card_accessor :variables, type: :json # Formula, WikiRatings, and Descendants (not Scores)
card_accessor :rubric, type: :json # Scores (of categorical metrics)
card_accessor :formula, type: :coffee_script # Formula and non-categorical Scores

event :recalculate_answers, delay: true, priority: 5 do
  deep_answer_update
end

# DEPENDEES = metrics that I depend on
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# overwritten in calculations
def direct_dependee_metrics
  []
end

# DEPENDERS = metrics that depend on me
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

def update_depender_values_for! company_id
  each_depender_metric do |metric|
    metric.calculate_answers company_id: company_id
  end
end

def all_depender_answer_ids
  ids = answer_ids
  each_depender_metric do |m|
    ids += m.answer_ids
  end
  ids
end

def all_depender_relation
  @all_depender_relation ||= Answer.where id: all_depender_answer_ids
end

# all metrics that depend on this metric
def depender_metrics
  depender_tree.metrics
end

# each metrics that depends on this metric
def each_depender_metric &block
  depender_tree.each_metric(&block)
end

def direct_depender_metrics
  (score_metrics + formula_metrics).uniq
end

def depender_tree
  DependerTree.new direct_depender_metrics
end

def score_metrics
  @score_metrics ||=
    Card.search type: :metric, left_id: id
end

# note: includes Formula, WikiRating, and Descendants but not Score metrics
def formula_metrics
  @formula_metrics ||=
    Card.search type: :metric, right_plus: [:variables, { refer_to: id }]
end

format :html do
  view :calculation_tab do
    [calculations_list, haml(:new_calculation_links)]
  end

  def tab_options
    { calculation: { count: card.direct_depender_metrics.size } }
  end

  def calculations_list
    card.direct_depender_metrics.map do |metric|
      nest metric, view: :bar
    end.join
  end

  def add_calculation_buttons
    card.calculation_types.map do |metric_type|
      link_to_card :metric, "Add new #{metric_type.cardname}",
                   path: { action: :new,
                           card: { subfields: { ":variables": card.name,
                                                ":metric_type": metric_type } } },
                   class: "btn btn-secondary"
    end
  end

  view :weight_row, cache: :never do
    weight_row 0
  end

  # used when metric is a variable in a WikiRating
  def weight_row weight=0
    haml :weight_row, weight: weight
  end

  view :formula_variable_row, cache: :never do
    formula_variable_row name: ""
  end

  def formula_variable_row hash
    hash.symbolize_keys!
    hash.delete :metric
    name = hash.delete :name
    haml :formula_variable_row, name: name, options: hash
  end
end
