def all_dependent_answer_ids
  ids = answer_ids
  each_dependent_metric do |m|
    ids += m.all_answers.pluck(:id)
  end
  ids
end

# # @return all metric cards that score this metric
# def each_dependent_score_metric
#   dependent_score_metrics.each do |m|
#     yield m
#   end
# end

def each_dependent_metric
  dependency_tree.each_metric { |m| yield m }
end

def dependency_tree
  direct_dependents = score_metrics + formula_metrics
  DependencyTree.new direct_dependents
end

def score_metrics
  Card.search type_id: MetricID, left_id: id
end

def formula_metrics
  @formula_metrics ||=
    Card.search type_id: MetricID, right_plus: ["formula", { refer_to: id }]
end
