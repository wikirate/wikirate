# NOTE: it would be nice to have these accessors in Abstract::Calculation, but
# if there they don't properly set the default cardtype for the fields

card_accessor :variables, type: :json # Formula, WikiRatings, and Descendants (not Scores)
card_accessor :formula, type: :coffeescript # Formula and non-categorical Scores
card_accessor :rubric, type: :json # Scores (of categorical metrics)

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
    Card.search type_id: MetricID, left_id: id
end

# note: includes Formula, WikiRating, and Descendants but not Score metrics
def formula_metrics
  @formula_metrics ||=
    Card.search type_id: MetricID, right_plus: [:variables, { refer_to: id }]
end

format :html do
  # used when metric is a variable in a WikiRating
  def weight_row weight=0, label=nil
    haml :weight_row, weight: weight, label: (label || render_thumbnail_no_link)
  end
end
