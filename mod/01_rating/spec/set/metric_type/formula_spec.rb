# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Formula do
  before do
    @name = 'Jedi+friendliness'
  end
  let(:metric) { Card[@name] }
  describe '#metric_type' do
    subject { metric.metric_type }
    it { is_expected.to eq 'Formula' }
  end
  describe '#metric_type_codename' do
    subject { metric.metric_type_codename }
    it { is_expected.to eq :formula }
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
    it { is_expected.to eq 'friendliness' }
  end
  describe '#metric_title_card' do
    subject { metric.metric_title_card }
    it { is_expected.to eq Card['friendliness'] }
  end
  describe '#question_card' do
    subject { metric.question_card.name }
    it { is_expected.to eq 'Jedi+friendliness+Question'}
  end
  describe '#value_type' do
    subject { metric.value_type }
    it { is_expected.to eq 'Number' }
  end
  describe '#categorical?' do
    subject { metric.categorical? }
    it { is_expected.to be_falsey }
  end
  describe '#researched?' do
    subject { metric.researched? }
    it { is_expected.to be_falsey }
  end
  describe '#scored?' do
    subject { metric.scored? }
    it { is_expected.to be_falsey }
  end

  def calc_value company='Samsung', year='2014'
    rating_value_card(company, year).content
  end

  def calc_value_card company='Samsung', year='2014'
    Card["Joe User+rating1+#{company}+#{year}+value"]
  end

  before do
    @metric = create_metric(
      name: 'formula1', type: :formula,
      formula: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
    )
  end

  context 'when created with formula' do
    it 'creates calculated values' do
      expect(calc_value).to eq('60')
      expect(calc_value 'Samsung', '2015').to eq('29')
      expect(calc_value 'Sony_Corporation').to eq('9')
      expect(rating_value_card 'Death_Star', '1977').to be_falsey
    end
  end

  context 'when created without formula' do
    before do
      @metric = create_metric name: 'formula2', type: :formula
    end

    it 'creates calculated values if formula created' do
      Card::Auth.as_bot do
        Card["#{@metric.name}+formula"].update_attributes!(
          type_id: Card::PlainTextID,
          content: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
        )
      end
      expect(calc_value).to eq('60')
      expect(calc_value 'Samsung', '2015').to eq('29')
      expect(calc_value 'Sony_Corporation').to eq('9')
      expect(rating_value_card 'Death_Star', '1977').to be_falsey
    end
  end

  context 'when formula changes' do
    def update_formula new_formula
      Card::Auth.as_bot do
        @metric.formula_card.update_attributes! content: new_formula
      end
    end
    it 'updates existing calculated value' do
      update_formula '{{Joe User+score1}}*4+{{Joe User+score2}}*2'
      expect(rating_value).to eq '50'
    end
    it 'removes incomplete calculated value' do
      update_formula '{{Joe User+score1}}*5+{{Joe User+score2}}*2+{{Joe User+score3}}'
      expect(rating_value_card 'Sony_Corporation', '2014').to be_falsey
    end
    it 'adds complete calculated value' do
      update_formula '{{Joe User+score1}}*5'
      expect(rating_value 'Death Star', '1977').to eq('25')
    end
  end

  context 'missing value' do
    it "doesn't create calculated value for companies with missing values" do
      expect(rating_value_card 'Death Star', '1977').to be_falsey
    end
    it "creates calculated value if missing value is added" do
      Card['Joe User+score2'].create_value company: 'Death Star',
                                           year: '1977',
                                           value: '2'
      expect(rating_value 'Death Star', '1977').to eq('29')
    end
  end

  context 'when input metric value changes' do
    it 'updates calculated value' do
      Card['Joe User+score1+Samsung+2014+value'].update_attributes! content: '1'
      expect(rating_value).to eq '15'
    end
    it 'removes incomplete calculated values' do
      Card['Joe User+score1+Samsung+2014+value'].delete
      expect(rating_value_card).to be_falsey
    end
  end
end
