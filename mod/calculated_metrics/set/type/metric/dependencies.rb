def update_depender_values_for! company_id, year
  each_depender_metric do |metric|
    metric.update_value_for! company: company_id, year: year
    # FIXME: this will break when year is specified in the formula.
  end
end

def all_depender_answer_ids
  ids = answer_ids
  each_depender_metric do |m|
    ids += m.answer_ids
  end
  ids
end

# all metrics that depend on this metric
def each_depender_metric
  depender_tree.each_metric { |m| yield m }
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
