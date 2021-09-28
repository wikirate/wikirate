card_accessor :formula, type: PhraseID
card_accessor :metric_variables

Card::Content::Chunk::FormulaInput # trigger load.  might be better place?

delegate :parser, :calculator_class, to: :formula_card

def calculator parser_method=nil
  p = parser
  p.send parser_method if parser_method
  calculator_class.new p, normalizer: Answer.method(:value_to_lookup),
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
