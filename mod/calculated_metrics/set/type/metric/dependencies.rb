def all_dependent_answer_ids
  ids = answer_ids
  each_dependent_metric do |m|
    ids += m.researched_answers.pluck(:id)
  end
  ids
end

def each_dependent_metric
  dependency_tree.each_metric { |m| yield m }
end

# note: #formula_metrics will find score metrics when scored by formula
# but not when scored by mapping.
def directly_dependent_metrics
  (score_metrics + formula_metrics).uniq
end

def dependency_tree
  DependencyTree.new directly_dependent_metrics
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
