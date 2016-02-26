# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Score do
  describe 'score card' do
    subject { Card[:score].to be_truthy }
    it { is_expected.to be_truthy }
    it 'has codename' do
      expect(subject.codename).to eq 'score'
    end
    it 'has type "metric type"' do
      expect(subject.type_id).to eq Card::MetricTypeID
    end
  end

  it 'calculate score'  do
    Card::Auth.as_bot do
      Card.create!(
        name: 'Force score', type_id: Card::MetricID,
        subcards: {
          '+*metric type' => '[[Score]]',
          '+formula' => '{{Jedi+deadliness}}/10 - 5'
        }
      )
    end

    expect(Card['force score+Death Star+1977']).to be_truthy
    expect(Card['force score+Death Star+1977+value'].content).to eq '5'
  end

  it 'calculate more complicated scores'  do
    Card::Auth.as_bot do
      Card.create!(
        name: 'Force score', type_id: Card::MetricID,
        subcards: {
          '+*metric type' => '[[Score]]',
          '+formula' => '{{Jedi+deadliness}}/10 - 5 + ' \
                        'Boole[{{Jedi+disturbances in the Force}} == "yes"]'
        }
      )
    end

    expect(Card['force score+Death Star+1977+value'].content).to eq '6'
  end
end
