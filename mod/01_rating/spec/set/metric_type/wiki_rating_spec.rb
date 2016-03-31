# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::WikiRating do
  let(:metric_type) { :wiki_rating }
  def rating_value company='Samsung', year='2014'
    rating_value_card(company, year).content
  end

  def rating_value_card company='Samsung', year='2014'
    Card["Joe User+rating1+#{company}+#{year}+value"]
  end

  before do
    create_metric name: 'score1', type: :researched do
      Samsung 2014 => 10, 2015 => 5
      Sony_Corporation 2014 => 1
      Death_Star 1977 => 5
    end
    create_metric name: 'score2', type: :researched do
      Samsung 2014 => 5, 2015 => 2
      Sony_Corporation 2014 => 2
    end
    create_metric name: 'score3', type: :researched do
      Samsung 2014 => 1, 2015 => 1
    end
    @metric = create_metric(
      name: 'rating1', type: :wiki_rating,
      formula: '{"Joe User+score1":"60","Joe User+score2":"40"}'
    )
  end

  context 'when created with formula' do
    it 'creates rating values' do
      expect(rating_value).to eq('8')
      expect(rating_value 'Samsung', '2015').to eq('3.8')
      expect(rating_value 'Sony_Corporation').to eq('1.4')
      expect(rating_value_card 'Death_Star', '1977').to be_falsey
    end
  end

  context 'when created without formula' do
    before do
      @metric = create_metric name: 'rating2', type: :wiki_rating
    end
    it 'has empty json hash as formula' do
      expect(Card["#{@metric.name}+formula"].content).to eq '{}'
    end
    it 'creates rating values if formula updated' do
      Card::Auth.as_bot do
        @metric.formular_card.update_attributes!(
          type_id: Card::PlainTextID,
          content: '{"Joe User+score1":"60","Joe User+score2":"40"}'
        )
       end
      expect(rating_value).to eq('8')
      expect(rating_value 'Samsung', '2015').to eq('3.8')
      expect(rating_value 'Sony_Corporation').to eq('1.4')
      expect(rating_value_card 'Death_Star', '1977').to be_falsey
    end
  end

  context 'when formula changes' do
    def update_weights weights
      @metric.formula_card.update_attributes! content: weights.to_json
    end
    it 'updates existing rating value' do
      update_weights 'Joe User+score1' => 40, 'Joe User+score2' => 60
      expect(rating_value).to eq '50'
    end
    it 'removes incomplete rating value' do
      update_formula 'Joe User+score1' => 40, 'Joe User+score2' => 40,
                     'Joe User+score3' => 20
      expect(rating_value_card 'Sony_Corporation', '2014').to be_falsey
    end
    it 'adds complete rating value' do
      update_formula 'Joe User+score1' => 100
      expect(rating_value 'Death Star', '1977').to eq('25')
    end
  end

  context 'you are not allowed to add metrics that are no scores' do

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
