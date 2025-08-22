# NOTE: it would be nice to have these accessors in Abstract::Calculation, but
# if there they don't properly set the default cardtype for the fields

card_accessor :variables, type: :json # Formula, Ratings, and Descendants (not Scores)
card_accessor :rubric, type: :json # Scores (of categorical metrics)
card_accessor :formula, type: :coffee_script # Formula and non-categorical Scores
card_accessor :license

event :recalculate_answers, delay: true, priority: 5 do
  calculate_answers
end

event :disallow_input_deletion, :validate, on: :delete do
  return unless formula_metrics.present?

  errors.add :content, "Cannot delete a metric that other metrics depend on"
end

# an unorthodox metric is a calculated metric that directly depends on an answer
# that is not for the same company and year
def unorthodox?
  false
end

def orthodox?
  !unorthodox?
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
    metric.calculate_direct_answers company_id: company_id
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
  @all_depender_relation ||= ::Answer.where id: all_depender_answer_ids
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
  @depender_tree ||= DependencyTree.new :depender, self
end

def dependee_metrics
  dependee_tree.metrics
end

def dependee_tree
  @dependee_tree ||= DependencyTree.new :dependee, self
end

def score_metrics
  @score_metrics ||=
    Card.search type: :metric, left_id: id
end

# note: includes Formula, Rating, and Descendants but not Score metrics
def formula_metrics
  @formula_metrics ||=
    id ? (Card.search type: :metric, right_plus: [:variables, { refer_to: id }]) : []
end

def update_latest company_id=nil
  rel = company_id ? answers.where(company_id: company_id) : answers
  rel.update_all latest: false
  latest_rel(rel).pluck(:id).each_slice(25_000) do |ids|
    ::Answer.where("id in (#{ids.join ', '})").update_all latest: true
  end
end

private

def latest_rel rel
  rel.where <<-SQL
      NOT EXISTS (
        SELECT * FROM answers a1
        WHERE a1.metric_id = answers.metric_id
        AND a1.company_id = answers.company_id
        AND a1.year > answers.year
      )
  SQL
end

format :html do
  view :calculation_tab do
    if card.license_card.nonderivative?
      "Calculated metrics are not allowed for metrics with a non-derivative license"
    else
      [calculations_list, haml(:new_calculation_links)]
    end
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
                           card: { fields: { ":variables": card.name,
                                             ":metric_type": metric_type } } },
                   class: "btn btn-secondary"
    end
  end

  view :weight_row, cache: :never do
    weight_row 0
  end

  # used when metric is a variable in a Rating
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

  def metric_tree_item detail=nil
    wrap_with :div, class: "static-tree-item" do
      metric_tree_item_title detail: detail
    end
  end

  def metric_tree_item_title detail:, answer: nil
    haml :metric_tree_item_title, detail: variable_detail(detail), answer: answer
  end

  private

  def variable_detail detail
    return detail unless detail.is_a? Hash
    detail = detail.clone

    variable = detail.delete :name

    haml :variable_detail, variable: variable, options: detail
  end
end
