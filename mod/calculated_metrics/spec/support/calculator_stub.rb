shared_context "with calculator stub" do
  def calculator formula, input_names=nil
    Formula::Calculator.new(formula_parser(formula, input_names))
  end

  def calculate formula, input_names=nil
    input_names &&= Array.wrap input_names
    described_class.new(parser(formula, input_names)).result
  end

  def parser_with_input names, year_options=nil, company_options=nil,
                              unknown_options=nil, not_researched_options=nil
    parser = Formula::Parser.new "", names
    year_options ||= []
    company_options ||= []
    unknown_options ||= []
    not_researched_options ||= []
    allow(parser).to receive(:input_cards) { names.map { |n| Card.fetch n } }
    allow(parser).to receive(:year_options).and_return year_options
    allow(parser).to receive(:company_options).and_return company_options
    allow(parser).to receive(:unknown_options).and_return unknown_options
    allow(parser).to receive(:not_researched_options).and_return not_researched_options

    %i[year company unknown not_researched].each do |opt|
      allow(parser).to receive("#{opt}_option".to_sym).and_call_original
    end
    parser
  end

  def formula_parser formula, input_names=nil
    Formula::Parser.new formula, input_names
  end

  alias_method :parser, :formula_parser
  alias_method :formula_card, :formula_parser
end
