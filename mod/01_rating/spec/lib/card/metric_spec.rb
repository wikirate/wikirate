describe Card::Metric do
  def add_metrics
    Card::Env[:protocol] = 'http://'
    Card::Env[:host] = 'wikirate.org'
    Card::Metric.create name: 'Jedi+disturbances in the Force',
                        value_type: 'Categorical' do
      value_options('yes', 'no')
      Death_Star '1977' => { value: 'yes',
                         source: 'http://www.wikiwand.com/en/Death_Star' }
    end
    Card::Metric.create name: 'Jedi+deadliness' do
      Death_Star '1977' => { value: 100,
                         source: 'http://www.wikiwand.com/en/Return_of_the_Jedi' }
    end
    Card::Metric.create name: 'Jedi+friendliness',
                        type: :formula,
                        formula: '1/{{Jedi+deadliness}}'
    Card::Metric.create name: 'Jedi+deadliness+Joe User',
                        type: :score,
                        formula: '{{Jedi+deadliness}}/10'
    Card::Metric.create name: 'Jedi+deadliness+Joe Camel',
                        type: :score,
                        formula: '{{Jedi+deadliness}}/20'
    Card::Metric.create name: 'Jedi+disturbances in the Force+Joe User',
                        type: :score,
                        formula: { yes: 10, no: 0 }
    Card::Metric.create(
      name: 'Jedi+darkness rating',
      type: :wiki_rating,
      formula: '({{Jedi+deadliness+Joe User}}+' \
               '{{Jedi+disturbances in the Force+Joe User}})/2'
    )
  end

  describe '#create' do
    subject { Card['MD+MT']}
    it 'small API test' do
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
      expect(Card['MD+MT+WithSource+2000+value'].content).to eq '50'
    end

    it 'big API test' do
      Card::Auth.as_bot do
        add_metrics
      end
      expect(Card['Jedi+disturbances in the Force+value type'].content)
        .to eq '[[Categorical]]'
      expect(Card['Jedi+disturbances in the Force+value options'].content)
        .to eq %w(yes no).to_pointer_content

    end

    it 'creates score' do
      Card::Auth.as_bot do
        Card::Metric.create name: 'Jedi+disturbances in the Force+Joe User',
                            type: :score,
                            formula: { yes: 10, no: 0 }
      end
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