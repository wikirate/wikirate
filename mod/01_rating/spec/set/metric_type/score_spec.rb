# -*- encoding : utf-8 -*-

describe Card::Set::MetricType::Score do
  it 'calculate score'  do
    Card.create!(
      name: 'Force score', type_id: Card::ScoredMetricID,
      subcards: {
        '+formula' => '{{Jedi+deadliness}}/10 - 5'
      }
    )
    expect(Card['force score+Death Star+1977']).to be_truthy
    expect(Card['force score+Death Star+1977+value'].content).to eq '5'
  end

  it 'calculate more complicated scores'  do
    Card.create!(
      name: 'Force score', type_id: Card::ScoredMetricID,
      subcards: {
        '+formula' => '{{Jedi+deadliness}}/10 - 5 + ' \
                      'Boole[{{Jedi+disturbances in the Force}} == "yes"]'
      }
    )
    expect(Card['force score+Death Star+1977+value'].content).to eq '6'
  end
end
