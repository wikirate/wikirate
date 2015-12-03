# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::WikiRating do
  # it_behaves_like 'calculation', :score do
  #    let(:formula) { }
  #  end
  let(:metric_type) { :wiki_rating }
  def rating_value company='Samsung', year='2014'
    rating_value_card(company, year).content
  end

  def rating_value_card company='Samsung', year='2014'
    Card["Joe User+rating1+#{company}+#{year}+value"]
  end

  before do
    create_metric name: 'score1', type: metric_type do
      Samsung 2014 => 10, 2015 => 5
      Sony_Corporation 2014 => 1
      Death_Star 1977 => 5
    end
    create_metric name: 'score2', type: metric_type do
      Samsung 2014 => 5, 2015 => 2
      Sony_Corporation 2014 => 2
    end
    create_metric name: 'score3', type: metric_type do
      Samsung 2014 => 1, 2015 => 1
    end
    @metric = create_metric(
      name: 'rating1', type: :wiki_rating,
      formula: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
    )
  end

  context 'when created' do
    it 'creates rating values' do
      expect(rating_value).to eq('60')
      expect(rating_value 'Samsung', '2015').to eq('29')
      expect(rating_value 'Sony_Corporation').to eq('9')
    end
  end

  context 'when formula changes' do
    def update_formula new_formula
      @metric.formula_card.update_attributes! content: new_formula
    end
    it 'updates existing rating value' do
      update_formula '{{Joe User+score1}}*4+{{Joe User+score2}}*2'
      expect(rating_value).to eq '50'
    end
    it 'removes incomplete rating value' do
      update_formula '{{Joe User+score1}}*5 + {{Joe User+score2}}*2 + ' \
                     '{{Joe User+score3}}'
      expect(rating_value_card 'Sony_Corporation', '2014').to be_falsey
    end
    it 'adds complete rating value' do
      update_formula '{{Joe User+score1}}*5'
      expect(rating_value 'Death Star', '1977').to eq('25')
    end
  end

  context 'missing value' do
    it "doesn't create rating value for companies with missing values" do
      expect(rating_value_card 'Death Star', '1977').to be_falsey
    end
    it "creates rating value if missing value is added" do
      Card['Joe User+score2'].create_value company: 'Death Star',
                                           year: '1977',
                                           value: '2'
      expect(rating_value 'Death Star', '1977').to eq('29')
    end
  end

  context 'when input metric value changes' do
    it 'updates rating value' do
      Card['Joe User+score1+Samsung+2014+value'].update_attributes! content: '1'
      expect(rating_value).to eq '15'
    end
    it 'removes incomplete rating values' do

      Card::Auth.as_bot do
        Card['Joe User+score1+Samsung+2014+value'].delete
      end
      expect(rating_value_card).to be_falsey
    end
  end

end
