# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Formula do
  def calculated_value company='Samsung', year='2014'
    calculated_value_card(company, year).content
  end

  def calculated_value_card company='Samsung', year='2014'
    Card["Joe User+rating1+#{company}+#{year}+value"]
  end

  before do
    create_metric name: 'score1', type: :formula do
      Samsung 2014 => 10, 2015 => 5
      Sony_Corporation 2014 => 1
      Death_Star 1977 => 5
    end
    create_metric name: 'score2', type: :formula do
      Samsung 2014 => 5, 2015 => 2
      Sony_Corporation 2014 => 2
    end
    create_metric name: 'score3', type: :formula do
      Samsung 2014 => 1, 2015 => 1
    end
    @metric = create_metric(
      name: 'rating1', type: :formula,
      formula: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
    )
  end

  describe 'formula with year reference' do
    it 'handles fixed year' do
      @metric = create_metric(
        name: 'rating1', type: :formula,
        formula: '{{Joe User+score1|year:2014}}}*2'
      )
      value_card = Card["#{@metric.name}+Samsung+2015+value"]
      expect(value_card.content).to eq '20'
    end
  end

  context 'when created' do
    it 'creates rating values' do
      expect(calculated_value).to eq('60')
      expect(calculated_value 'Samsung', '2015').to eq('29')
      expect(calculated_value 'Sony_Corporation').to eq('9')
    end
  end

  context 'when formula changes' do
    def update_formula new_formula
      @metric.formula_card.update_attributes! content: new_formula
    end
    it 'updates existing rating value' do
      update_formula '{{Joe User+score1}}*4+{{Joe User+score2}}*2'
      expect(calculated_value).to eq '50'
    end
    it 'removes incomplete rating value' do
      update_formula '{{Joe User+score1}}*5+{{Joe User+score2}}*2+{{Joe User+score3}}'
      expect(calculated_value_card 'Sony_Corporation', '2014').to be_falsey
    end
    it 'adds complete rating value' do
      update_formula '{{Joe User+score1}}*5'
      expect(calculated_value 'Death Star', '1977').to eq('25')
    end
  end

  context 'missing value' do
    it "doesn't create rating value for companies with missing values" do
      expect(calculated_value_card 'Death Star', '1977').to be_falsey
    end
    it "creates rating value if missing value is added" do
      Card['Joe User+score2'].create_value company: 'Death Star',
                                           year: '1977',
                                           value: '2'
      expect(calculated_value 'Death Star', '1977').to eq('29')
    end
  end

  context 'when input metric value changes' do
    it 'updates rating value' do
      Card['Joe User+score1+Samsung+2014+value'].update_attributes! content: '1'
      expect(calculated_value).to eq '15'
    end
    it 'removes incomplete rating values' do
      Card['Joe User+score1+Samsung+2014+value'].delete
      expect(calculated_value_card).to be_falsey
    end
  end
  
  
  
  describe '#valid_ruby_expression?' do
    subject do
      Card::Auth.as_bot do
        Card::Metric.create name: 'Jedi+evil rating', 
                            type: :wiki_rating
                     
      end
    end
    it 'allows math operations' do
      expect(subject.valid_ruby_expression? '5 * 4 / 2 - 2.3 + 5').to be_truthy
    end

    it 'allows parens' do
      expect(subject.valid_ruby_expression? '5 * (4 / 2) - 2').to be_truthy
    end

    it 'allows index access to args' do
      expect(subject.valid_ruby_expression? '5 * args[1] + 5').to be_truthy
    end

    it 'denies letters' do
      expect(subject.valid_ruby_expression? '5 * 4*a / 2 - 2 + 5').to be_falsey
    end
  end

  # -*- encoding : utf-8 -*-

  describe Card::Set::MetricType::Researched do
    let(:metric) { Card['Jedi+disturbances in the Force'] }

    describe '#metric_type' do
      subject { metric.metric_type }
      it { is_expected.to eq 'Researched' }
    end
    describe '#metric_type_codename' do
      subject { metric.metric_type_codename }
      it { is_expected.to eq :researched }
    end
    describe '#metric_designer' do
      subject { metric.metric_designer }
      it { is_expected.to eq 'Jedi' }
    end
    describe '#metric_designer_card' do
      subject { metric.metric_designer_card }
      it { is_expected.to eq Card['Jedi'] }
    end
    describe '#metric_title' do
      subject { metric.metric_title }
      it { is_expected.to eq 'disturbances in the Force' }
    end
    describe '#metric_title_card' do
      subject { metric.metric_title_card }
      it { is_expected.to eq Card['disturbances in the Force'] }
    end
    describe '#question_card' do
      subject { metric.question_card.name }
      it { is_expected.to eq 'Jedi+disturbances in the Force+Question'}
    end
    describe '#value_type' do
      subject { metric.value_type }
      it { is_expected.to eq 'Categorical' }
    end
    describe '#value_options' do
      subject { metric.value_options }
      it { is_expected.to eq %w(yes no) }
    end
    describe '#categorical?' do
      subject { metric.categorical? }
      it { is_expected.to be_truthy }
    end
    describe '#researched?' do
      subject { metric.researched? }
      it { is_expected.to be_truthy }
    end
    describe '#scored?' do
      subject { metric.scored? }
      it { is_expected.to be_falsey }
    end
  end
  
  
end
