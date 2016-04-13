# -*- encoding : utf-8 -*-

describe Card::MetricTypeSet do
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
      expect(card.this_is_rating).to be_truthy
    end
  end

  it 'works with new' do
    new_metric = Card.new type_id: Card::MetricID, '+*metric type' => '[[Formula]]'
    expect(new_metric.set_modules).to include(Card::Set::MetricType::Formula)
    expect(new_metric.metric_type).to eq 'Formula'
  end

  it 'works with create' do
    Card::Auth.as_bot do
      @new_metric = Card.create! name: 'metriy type test',
                                type_id: Card::MetricID,
                              '+*metric type' => '[[Formula]]'
    end
    expect(@new_metric.set_modules).to include(Card::Set::MetricType::Formula)
    expect(@new_metric.metric_type).to eq 'Formula'
  end
end