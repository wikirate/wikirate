describe Formula::Input do
  def chunk_include content
    Card::Content::Chunk::Include.new(
      Card::Content::Chunk::Include.full_match(content),
      Card::Content.new(content, Card.new(name:'test'))
    )
  end
  let(:formula_card) do
    formula = double(Card)
    allow(formula).to receive(:content)
                         .and_return(@nests.join)
    allow(formula).to receive(:each_nested_chunk) do |&block|
      @nests.each do |n|
        block.call(chunk_include(n))
      end
    end
    allow(formula).to receive(:cast_input) do |v|
      v.to_f
    end

    allow(formula).to receive(:normalize_value) do |v|
      v
    end
    formula
  end

  subject { FormulaInput.new formula_card }
  it 'single input' do
    @nests = ['{{Jedi+deadliness}}']
    #@formula = "#{@nests.first}*2"
    expect(subject.input(1977, 'Death Star')).to eq [100.0]
  end

  it 'two metrics' do
    @nests = ['{{Jedi+deadliness}}', '{{Joe User+score1}}']
    #@formula = "#{@nests.first}*2"
    expect(subject.input(1977, 'Death Star')).to eq [100.0, 5.0]
  end
end