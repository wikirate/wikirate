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

# note: #formula_metrics will find score metrics when scored by formula
# but not when scored by mapping.
def direct_depender_metrics
  (score_metrics + formula_metrics).uniq
end

def depender_tree
  DependerTree.new direct_depender_metrics
end

def score_metrics
  @score_metrics ||=
    Card.search type_id: MetricID, left_id: id
end

# note: includes score metrics
def formula_metrics
  @formula_metrics ||=
    Card.search type_id: MetricID, right_plus: ["formula", { refer_to: id }]
end

# depender = metrics that depend on me
# dependee = metrics that I depend on

def direct_dependee_metrics
  return [] unless calculated?

  formula_card&.item_names&.map(&:card)&.select { |i| i&.type_id == MetricID }
end
