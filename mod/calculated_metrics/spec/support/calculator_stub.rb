shared_context "with calculator stub" do
  def calculator formula
    Formula::Calculator.new(formula_parser(formula))
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

  def formula_parser formula
    Formula::Parser.new formula
  end

  alias_method :formula_card, :formula_parser

  # def chunk_list formula
  #   content_obj = Card::Content.new(formula, Card.new(name: "test"), chunk_list: :formula)
  #   content_obj.find_chunks(Card::Content::Chunk::FormulaInput)
  # end
  #
  # def stub_methods card, formula
  #   chunks = chunk_list formula
  #   allow(card).to receive(:clean_formula).and_return formula
  #   allow(card).to receive(:input_cards) { chunks.map(&:referee_card) }
  #   allow(card).to receive(:input_chunks).and_return chunks
  #   allow(card).to receive(:normalize_value) { |v| v }
  #   allow(card).to receive(:input_requirement).and_return :all
  #   allow(card).to receive(:company_options) { chunks.map { |ch| ch.options[:company] } }
  #   allow(card).to receive(:year_options) { chunks.map { |ch| ch.options[:year] } }
  #   allow(card).to receive(:unknown_options) { chunks.map { |ch| ch.options[:unknown] } }
  # end
end
