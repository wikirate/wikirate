describe RubyFormula do
  def chunk_include content
    Card::Content::Chunk::Include.new(
      Card::Content::Chunk::Include.full_match(content),
      Card::Content.new(content, Card.new(name:'test'))
    )
  end
  let(:formula) do
    formula = double(Card)
    allow(formula).to receive(:content)
                        .and_return @formula
    allow(formula).to receive(:each_nested_chunk) do |&block|
      @nests.each do |n|
        block.call(chunk_include(n))
      end
    end

    allow(formula).to receive(:normalize_value) do |v|
      v
    end
    formula
  end
  subject { Formula::Calculator::Ruby.new(formula).result }
  it 'simple formula' do
    @nests = ['{{Joe User+researched1}}']
    @formula = "#{@nests.first}*2"
    expect(subject[2011]).to eq 22.0
    expect(subject[2012]).to eq 24.0
    expect(subject[2013]).to eq 26.0
  end
  it 'sum' do
    @nests = ['{{Joe User+researched1|year:-2..0}}']
    @formula = "Sum[#{@nests.first}]"
    expect(subject[2011]).to eq({})
    expect(subject[2012]['samsung']).to eq 33.0
    expect(subject[2013]['samsung']).to eq 36.0
  end
end