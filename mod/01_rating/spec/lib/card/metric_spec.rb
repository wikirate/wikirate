describe Card::Metric do
  describe '#create' do
    subject { Card['MD+MT']}
    it 'API test' do
      Card::Auth.as_bot do
        Card::Metric.create name: 'MD+MT',  formula: '1' do
          MyCompany 2000 => 50, 2001 => 100
          WithSource 2000 => { value: 50, source: 'http://example.com' }
        end
      end
      is_expected.to be_truthy
      expect(subject.type_id).to eq Card::MetricID
      expect(subject.field(:formula).content).to eq '1'
      expect(subject.metric_type).to eq 'Researched'

      value = subject.field('MyCompany').field('2000')
      expect(value).to be_truthy
      expect(value.type_id).to eq Card::MetricValueID
      expect(value.field('value').content).to eq '50'
      expect(Card['MD+MT+MyCompany+2001+value'].content).to eq '100'
      expect(Card['MD+MT+WithSource+2000+source'].item_cards.first.field('link').content)
        .to eq('http://example.com')
      expect(Card['MD+MT+WithSource+2000+value'].content).to '50'
    end
  end

  describe 'Card#new' do
    it 'recognizes metric type' do
      metric = Card.new name: 'MT+MD', type_id: Card::MetricID,
                        "+*metric type"=>"[[Researched]]"
      expect(metric.set_format_modules(Card::HtmlFormat)).to include
      (Card::Set::MetricType::Researched::HtmlFormat)
    end
  end
end