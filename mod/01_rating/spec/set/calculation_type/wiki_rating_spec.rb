# -*- encoding : utf-8 -*-

describe Card::Set::CalculationType::WikiRating do
  def rating_value company='Samsung', year='2014'
    rating_value_card(company, year).content
  end

  def rating_value_card company='Samsung', year='2014'
    Card["Joe User+rating1+#{company}+#{year}+value"]
  end

  before do
    create_metric name: 'score1', type: :score do
      Samsung 2014 => 10, 2015 => 5
      Sony_Corporation 2014 => 1
      Death_Star 1977 => 5
    end
    create_metric name: 'score2', type: :score do
      Samsung 2014 => 5, 2015 => 2
      Sony_Corporation 2014 => 2
    end
    create_metric name: 'score3', type: :score do
      Samsung 2014 => 1, 2015 => 1
    end
    @metric = create_metric(
      name: 'rating1', type: :wiki_rating,
      formula: '{{Joe User+score1}}*5+{{Joe User+score2}}*2'
    )
  end

  it 'creates rating values' do
    expect(rating_value).to eq('60')
    expect(rating_value 'Samsung', '2015').to eq('29')
    expect(rating_value 'Sony_Corporation').to eq('9')
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
      update_formula '{{Joe User+score1}}*5+{{Joe User+score2}}*2+{{Joe User+score3}}'
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
      binding.pry
      Card['Joe User+score2'].create_value company: 'Death Star',
                                           year: '1977',
                                           value: '5'
      expect(rating_value 'Death Star', '1977').to eq('29')
    end
  end

  context 'when input metric value changes' do
    it 'updates rating value' do
      rating_value_card.update_attributes! content: '1'
      expect(rating_value).to eq '7'
    end
    it 'removes incomplete rating values' do
      rating_value_card.delete
      expect(rating_value_card).to be_falsey
    end
  end


  describe '#valid_ruby_expression?' do
    subject do
      Card::Auth.as_bot do
        Card.create! name: 'Jedi+evil rating', type_id: Card::MetricID,
                     subcards: {
                      '+*metric type' => "[[#{Card[:wiki_rating].name}]]",
                     }
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
end
