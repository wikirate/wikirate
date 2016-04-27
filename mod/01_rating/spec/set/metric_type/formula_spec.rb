# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Formula do
  describe 'formula card' do
    subject { Card[:formula] }
    it { is_expected.to be_truthy }
    it 'has codename' do
      expect(subject.codename).to eq 'formula'
    end
    it 'has type "metric type"' do
      expect(subject.type_id).to eq Card['metric type'].id
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
    subject { Card["#{metric.name}+Apple Inc+2015+value"].content}

    context 'single year' do
      let(:metric) do
        create_metric(
          name: 'rating1', type: :formula,
          formula: "{{ Joe User+researched1|year:#{@year_expr} }}+" \
                   '{{Joe User+score1}}'
        )
      end

      it 'fixed year' do
        @year_expr = '2014'
        is_expected.to eq '114'
      end
      it 'relative year' do
        @year_expr = '-2'
        is_expected.to eq '113'
      end
      it 'current year' do
        @year_expr = '0'
        is_expected.to eq '200'
      end
    end

    context 'sum of' do
      let(:metric) do
        create_metric(
          name: 'rating1', type: :formula,
          formula: "Sum[{{Joe User+researched1|year:#{@year_expr} }}]+" \
                   '{{Joe User+score1}}'
        )
      end

      it 'relative range' do
        @year_expr = '-3..-1'
        is_expected.to eq '136'
      end
      it 'relative range with 0' do
        @year_expr = '-3..0'
        is_expected.to eq '141'
      end
      it 'relative range with ?' do
        @year_expr = '-3..?'
        is_expected.to eq '141'
      end
      it 'fixed range' do
        @year_expr = '2012..2013'
        is_expected.to eq '125'
      end
      it 'fixed start' do
        @year_expr = '2012..0'
        is_expected.to eq '154'
      end
      it 'list of years' do
        @year_expr = '2012, 2014'
        is_expected.to eq '126'
      end
    end
  end

  describe 'basic properties' do
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
      it { is_expected.to eq nil }
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
  end

  def calc_value company='Samsung', year='2014'
    calc_value_card(company, year).content
  end

  def calc_value_card company='Samsung', year='2014'
    Card["Joe User+#{@metric_title}+#{company}+#{year}+value"]
  end

  context 'when created with formula' do
    before do
      @metric_title = 'formula1'
      Card::Auth.as_bot do
        @metric = create_metric(
          name: @metric_title, type: :formula,
          formula: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
        )
      end
    end

    it 'creates calculated values' do
      expect(calc_value).to eq('60')
      expect(calc_value 'Samsung', '2015').to eq('29')
      expect(calc_value 'Sony_Corporation').to eq('9')
      expect(calc_value_card 'Death_Star', '1977').to be_falsey
    end

    context 'and formula changes' do
      def update_formula new_formula
        Card::Auth.as_bot do
          @metric.formula_card.update_attributes! content: new_formula
        end
      end
      it 'updates existing calculated value' do
        update_formula '{{Joe User+score1}}*4+{{Joe User+score2}}*2'
        expect(calc_value).to eq '50'
      end
      it 'removes incomplete calculated value' do
        update_formula '{{Joe User+score1}}*5+{{Joe User+score2}}*2+{{Joe User+score3}}'
        expect(calc_value_card 'Sony_Corporation', '2014').to be_falsey
      end
      it 'adds complete calculated value' do
        update_formula '{{Joe User+score1}}*5'
        expect(calc_value 'Death Star', '1977').to eq('25')
      end
    end

    context 'and input metric value is missing' do
      it "doesn't create calculated value" do
        expect(calc_value_card 'Death Star', '1977').to be_falsey
      end
      it "creates calculated value if missing value is added" do
        Card::Auth.as_bot do
          Card['Joe User+score2'].create_value company: 'Death Star',
                                               year: '1977',
                                               value: '2',
                                               source: get_a_sample_source
        end
        expect(calc_value 'Death Star', '1977').to eq('29')
      end
    end

    context 'and input metric value changes' do
      it 'updates calculated value' do
        Card['Joe User+score1+Samsung+2014+value'].update_attributes! content: '1'
        expect(calc_value).to eq '15'
      end
      it 'removes incomplete calculated values' do
        Card::Auth.as_bot do
          Card['Joe User+score1+Samsung+2014+value'].delete
        end
        expect(calc_value_card).to be_falsey
      end
    end
  end

  context 'when created without formula' do
    before do
      @metric_title = 'formula2'
      @metric = create_metric name: @metric_title, type: :formula
    end

    it 'creates calculated values if formula created' do
      Card::Auth.as_bot do
        Card.create! name: "#{@metric.name}+formula",
          type_id: Card::PlainTextID,
          content: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'

      end
      expect(calc_value).to eq('60')
      expect(calc_value 'Samsung', '2015').to eq('29')
      expect(calc_value 'Sony_Corporation').to eq('9')
      expect(calc_value_card 'Death_Star', '1977').to be_falsey
    end
  end

  it 'handles wolfram formula' do
    Card::Auth.as_bot do
      Card::Metric.create(
        name: 'Jedi+Force formula',
        type: :formula,
        formula: '{{Jedi+deadliness}}/10 - 5 + ' \
               'Boole[{{Jedi+disturbances in the Force}} == "yes"]'
      )
    end
    expect(Card['Jedi+Force formula+Death Star+1977+value'].content).to eq '6'
  end
end
