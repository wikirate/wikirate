shared_context "with formula stub" do
  def formula_card_with_input names, requirement, year_options=nil, company_options=nil
    card = double(Card)
    year_options ||= []
    company_options ||= []
    allow(card).to receive(:input_requirement).and_return requirement
    allow(card).to receive(:input_cards) { names.map { |n| Card.fetch n } }
    allow(card).to receive(:year_options).and_return year_options
    allow(card).to receive(:company_options).and_return company_options
    card
  end

  def formula_card formula
    card = double(Card)
    stub_methods card, formula
    card
  end

  def chunk_list formula
    content_obj = Card::Content.new(formula, Card.new(name: "test"), chunk_list: :formula)
    content_obj.find_chunks(Card::Content::Chunk::FormulaInput)
  end

  def stub_methods card, formula
    chunks = chunk_list formula
    allow(card).to receive(:clean_formula).and_return formula
    allow(card).to receive(:input_cards) { chunks.map(&:referee_card) }
    allow(card).to receive(:input_chunks).and_return chunks
    allow(card).to receive(:normalize_value) { |v| v }
    allow(card).to receive(:input_requirement).and_return :all
    allow(card).to receive(:company_options) { chunks.map { |ch| ch.options[:company] } }
    allow(card).to receive(:year_options) { chunks.map { |ch| ch.options[:year] } }
  end
end
