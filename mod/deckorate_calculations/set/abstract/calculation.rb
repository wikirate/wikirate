card_accessor :metric_variables # deprecated

def calculator variant=:standard
  calculator_class.new input_array(variant),
                       formula: formula,
                       normalizer: Answer.method(:value_to_lookup),
                       years: year_card.item_names,
                       companies: company_group_card.company_ids
end

# update all answers of this metric and the answers of all dependent metrics
def deep_answer_update args={}
  calculate_answers args
  each_depender_metric { |m| m.send :calculate_answers, args }
end

# param @args [Hash] :company_id, :year, both, or neither.
# TODO: convert to :companies and :years as named arguments to be consistent with
# calculator#result
def calculate_answers args={}
  c = ::Calculate.new self, args
  c.prepare
  c.transact
  c.clean
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

format :html do
  view :formula do
    field_nest card.formula_field, view: :titled, title: "Formula"
  end

  view :main_details do
    [nest_about, render_formula, nest_methodology]
  end

  view :new_formula, unknown: true do
    wrap do
      card_form view: :new, method: :get do
        with_nest_mode :edit do
          field_nest card.formula_field, view: :content_formgroups
        end
      end
    end
  end
end
