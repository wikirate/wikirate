# -*- encoding : utf-8 -*-

describe Card::MetricMethodSet do
  it 'works' do
    Card::Auth.as_bot do
      card = Card.create! name: 'Designer+MetricName', type_id: Card::MetricID,
        subcards: { '+*metric method' => {
          content: 'calculation',
          type_id: Card::PhraseID
        }}
      expect(card.calculated_metric?).to be_truthy
    end
  end
end