include_set Abstract::LazyTree

delegate :unorthodox?, to: :variables_card

def calculator variant=:standard
  calculator_class.new input_array(variant),
                       formula: formula,
                       normalizer: ::Answer.method(:value_to_lookup),
                       years: year_card.item_names,
                       companies: calculator_company_ids
end

def calculator_company_ids
  company_group_card.try(:company_ids) || []
end

# update all answers of this metric and the answers of all metrics that
# depend on this one
def calculate_answers args={}
  calculate_direct_answers args
  each_depender_metric { |m| m.calculate_direct_answers args }
end

# param @args [Hash] :company_id, :year, both, or neither.
# TODO: convert to :companies and :years as named arguments to be consistent with
# calculator#result
def calculate_direct_answers args={}
  c = ::Calculate.new self, args
  c.prepare
  c.transact
  c.clean
end

# USE WITH CAUTION
# This method works DOWN the dependency tree and recalculates answers. It's not a
# typical pattern and was written as a bit of hail mary attempt to fix some confusing
# results. But it can be very computationally expensive, and if things are working
# properly it should never be necessary.
def recalculate_all_answers dependers: true
  return if researched?

  direct_dependee_metrics.each { |m| m.recalculate_all_answers dependers: false }
  dependers ? calculate_answers : calculate_direct_answers
end

def input_array variant
  base_input_array.tap do |array|
    array.each { |input| send "#{variant}_formula_input", input }
  end
end

def base_input_array
  variables_card.input_array
end

def standard_formula_input input
  input
end

def raw_formula_input input
  input.merge! unknown: "Unknown", not_researched: "No value"
end

def processed_formula_input input
  input.merge! unknown: :process, not_researched: :process
end

def direct_dependee_metrics
  return [] unless variables.present?

  # TODO: simplify once we get rid of Yearly Variables
  variables_card&.item_names&.map(&:card)&.select { |i| i&.type_id == MetricID }
end

def formula_field
  :variables
end

def formula_field?
  field? formula_field
end

# metric's answers depend ONLY on other answers for the same company and year
def orthodox_tree?
  !unorthodox_tree?
end

def unorthodox_tree?
  unorthodox? || dependee_tree.metrics.find(&:unorthodox?)
end

def input_metrics_and_detail
  variables_card.metric_and_detail
end

format :html do
  def tab_list
    super.insert 2, :input_answer
  end

  def tab_options
    super.merge input_answer: { label: "Inputs" }
  end

  view :new do
    params[:button] == "formulated" ? super() : render_new_formula
  end

  view :formula do
    field_nest card.formula_field, view: :titled, title: "Formula"
  end

  view :new_formula, unknown: true, cache: :never do
    wrap do
      card_form({ action: :new, mark: :metric }, method: :get, redirect: true) do
        with_nest_mode :edit do
          [haml(:new_formula_form), new_formula_hidden_tags]
        end
      end
    end
  end

  view :input_answer_tab, template: :haml

  def metric_tree_item detail=nil
    tree_item metric_tree_item_title(detail: detail),
              body: card_stub(view: :metric_tree_branch)
  end

  view :metric_tree_branch, cache: :never do
    field_nest :variables, view: :core
  end

  def algorithm
    field_nest :variables, view: :algorithm
  end

  def format_algorithm algorithm
    haml :algorithm, algorithm: algorithm
  end

  private

  def new_formula_hidden_tags
    hidden_tags card: { fields: { ":metric_type": card.metric_type },
                        name: card.name }
  end
end
