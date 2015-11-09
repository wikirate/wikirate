describe Card::Set::Type::ScoredMetric do
  it 'calculate score'  do
    scored_metric = Card.create!(
      name: 'Force score', :type_id=>Card::ScoredMetricID,
      subcards: {
        '+formula' => '{{Jedi+deadliness}}/10 - 5'
      }
    )
    expect(Card['force score+Death Star+1977']).to be_truthy
    expect(Card['force score+Death Star+1977+value'].content).to eq "5"
  end

  it 'calculate more complicated scores'  do
    scored_metric = Card.create!(
      name: 'Force score', :type_id=>Card::ScoredMetricID,
      subcards: {
        '+formula' => '{{Jedi+deadliness}}/10 - 5 + Boole[{{Jedi+disturbances in the Force}} == "yes"]'
      }
    )
    expect(Card['force score+Death Star+1977+value'].content).to eq "6"
  end

end