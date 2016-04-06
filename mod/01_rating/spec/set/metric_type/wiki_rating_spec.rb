# -*- encoding : utf-8 -*-

# available scores in test db
#  Joe User+score1
#   Samsung          2014 => 10, 2015 => 5
#   Sony_Corporation 2014 => 1
#   Death_Star       1977 => 5
#
#  Joe User+score2
#   Samsung          2014 => 5, 2015 => 2
#   Sony_Corporation 2014 => 2
#
#  Joe User+score3
#   Samsung          2014 => 1, 2015 => 1
describe Card::Set::MetricType::WikiRating do
  let(:metric_type) { :wiki_rating }
  describe 'formula card' do
    subject { Card[:wiki_rating] }
    it { is_expected.to be_truthy }
    it 'has codename' do
      expect(subject.codename).to eq 'wiki_rating'
    end
    it 'has type "metric type"' do
      expect(subject.type_id).to eq Card['metric type'].id
    end
  end

  def rating_value company='Samsung', year='2014'
    rating_value_card(company, year).content
  end

  def rating_value_card company='Samsung', year='2014'
    Card["Joe User+#{@metric_title}+#{company}+#{year}+value"]
  end

  context 'when created with formula' do
    before do
      @metric_title = 'rating1'
      @metric = create_metric(
        name: @metric_title, type: :wiki_rating,
        formula: '{"Joe User+score1":"60","Joe User+score2":"40"}'
      )
    end

    it 'creates rating values' do
      expect(rating_value).to eq('8')
      expect(rating_value 'Samsung', '2015').to eq('3.8')
      expect(rating_value 'Sony_Corporation').to eq('1.4')
      expect(rating_value_card 'Death_Star', '1977').to be_falsey
    end

    context 'and formula changes' do
      def update_weights weights
        @metric.formula_card.update_attributes! content: weights.to_json
      end
      it 'updates existing rating value' do
        update_weights 'Joe User+score1' => 40, 'Joe User+score2' => 60
        expect(rating_value).to eq '7'
      end
      it 'removes incomplete rating value' do
        update_weights 'Joe User+score1' => 40, 'Joe User+score2' => 40,
                       'Joe User+score3' => 20
        expect(rating_value_card 'Sony_Corporation', '2014').to be_falsey
      end
      it 'adds complete rating value' do
        # Death Star has only a value for +score1
        # so if we restrict the formula to +score1 values
        # Death Star has to get a rating value
        update_weights 'Joe User+score1' => 100
        expect(rating_value 'Death Star', '1977').to eq('5')
      end
    end

    context 'and input metric value changes' do
      it 'updates rating value' do
        Card['Joe User+score1+Samsung+2014+value'].update_attributes! content: '1'
        expect(rating_value).to eq '2.6'
      end
      it 'removes incomplete rating values' do
        Card::Auth.as_bot do
          Card['Joe User+score1+Samsung+2014+value'].delete
        end
        expect(rating_value_card).to be_falsey
      end
    end

    context 'and input metric value is missing' do
      it "doesn't create rating value" do
        expect(rating_value_card 'Death Star', '1977').to be_falsey
      end
      it "creates rating value if missing value is added" do
        Card::Auth.as_bot do
          Card['Joe User+score2'].create_value company: 'Death Star',
                                               year: '1977',
                                               value: '2',
                                               source: get_a_sample_source
        end
        expect(rating_value 'Death Star', '1977').to eq('3.8')
      end
    end
  end

  context 'when created without formula' do
    before do
      @metric_title = 'rating2'
      @metric = create_metric name: @metric_title, type: :wiki_rating
    end
    it 'has empty json hash as formula' do
      expect(Card["#{@metric.name}+formula"].content).to eq '{}'
    end
    it 'creates rating values if formula updated' do
      Card::Auth.as_bot do
        @metric.formula_card.update_attributes!(
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

  context 'you are not allowed to add metrics that are no scores' do
  end
end
