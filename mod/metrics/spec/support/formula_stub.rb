shared_context "formula_stub" do
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
    allow(card).to receive(:content).and_return formula
    allow(card).to receive(:input_cards) { chunks.map(&:referee_card) }
    allow(card).to receive(:input_chunks).and_return chunks
    allow(card).to receive(:normalize_value) { |v| v }
  end
end
