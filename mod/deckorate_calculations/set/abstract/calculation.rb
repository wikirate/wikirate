card_accessor :metric_variables # deprecated

def calculator
  calculator_class.new input_array,
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

def input_array
  puts "input array: #{variables_card.parse_content}"
  variables_card.parse_content
end

format :html do
  view :main_details do
    [nest_about, render_formula, nest_methodology]
  end

  view :formula do
    field_nest :formula, view: :titled
  end
end
