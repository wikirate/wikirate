# -*- encoding : utf-8 -*-

describe Card::CalculationTypeSet do
  it 'works' do
    Card::Auth.as_bot do
      Card[:rating].update_attributes! :name=>'Rating'
      card = Card.create! name: 'Designer+MetricName', type_id: Card::MetricID,
        subcards: {
          '+*metric method' => {
            content: 'calculation',
            type_id: Card::PhraseID
          },
          '+*calculation type' => {
            content: 'rating',
            type_id: Card::PhraseID
          }
        }
        binding.pry
      expect(card.this_is_rating).to be_truthy
    end
  end
end