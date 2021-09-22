shared_context "with calculator stub" do
  def calculator formula, input_names=nil
    Calculate::Calculator.new(formula_parser(formula, input_names))
  end

  def calculate formula, input_names=nil
    input_names &&= Array.wrap input_names
    described_class.new(parser(formula, input_names)).result
  end

  def parser_with_input names, options={}
    parser = Calculate::Parser.new "", names
    allow(parser).to receive(:input_cards) { names.map { |n| Card.fetch n } }
    %i[year company unknown not_researched].each do |opt|
      return_val = options[opt] || []
      allow(parser).to receive("#{opt}_options".to_sym).and_return return_val
      allow(parser).to receive("#{opt}_option".to_sym).and_call_original
    end
    parser
  end

  def formula_parser formula, input_names=nil
    Calculate::Parser.new formula, input_names
  end

  alias_method :parser, :formula_parser
  alias_method :formula_card, :formula_parser
end
