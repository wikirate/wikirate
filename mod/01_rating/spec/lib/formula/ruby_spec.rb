describe Formula::Ruby do
  let(:formula) do
    formula = double(Card)
    content_obj =
      Card::Content.new(@formula, Card.new(name:'test'), chunk_list: :formula)
    @chunks = content_obj.find_chunks(Card::Content::Chunk::FormulaInput)
    allow(formula).to receive(:content).and_return @formula
    allow(formula).to receive(:input_cards) do
      @chunks.map do |chunk|
        chunk.referee_card
      end
    end
    allow(formula).to receive(:input_chunks).and_return @chunks
    allow(formula).to receive(:normalize_value) do |v|
      v
    end
    formula
  end
  before do
    Card::Auth.as_bot do
      Card::Metric.create name: 'Joe User+researched1',
                          type: :researched,
                          random_source: true do

        Apple_Inc  '2010' => 10, '2011' => 11, '2012' => 12,
                   '2013' => 13, '2014' => 14
      end
    end
  end
  subject { Formula::Ruby.new(formula).result }
  it 'simple formula' do
    @nests = ['{{Joe User+researched1}}']
    @formula = "#{@nests.first}*2"
    expect(subject[2011]['apple_inc']).to eq 22.0
    expect(subject[2012]['apple_inc']).to eq 24.0
    expect(subject[2013]['apple_inc']).to eq 26.0
  end
  describe 'functions' do
    before do
      @nest = '{{Joe User+researched1|year:-2..0}}'
    end
    it 'sum' do
      @formula = "Sum[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]['apple_inc']).to eq 33.0
      expect(subject[2013]['apple_inc']).to eq 36.0
    end
    it 'max' do
      @formula = "Max[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]['apple_inc']).to eq 12.0
      expect(subject[2013]['apple_inc']).to eq 13.0
    end
    it 'min' do
      @formula = "Min[#{@nest}]"
      expect(subject[2011]).to eq({})
      expect(subject[2012]['apple_inc']).to eq 10.0
      expect(subject[2013]['apple_inc']).to eq 11.0
    end
  end

  describe 'yearly variables' do
    before do
      Card::Auth.as_bot do
        #Card.create name: 'yearly var', type: 'yea'
      end
    end
  end
end
