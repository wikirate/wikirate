# encoding: UTF-8

describe Card::MetricTypePlusRightSet do
  it 'works' do
    Card::Auth.as_bot do
      card = Card.create! name: 'Designer+MetricName', type_id: Card::MetricID,
        subcards: {
          '+*metric type' => {
            content: 'wiki_rating',
            type_id: Card::PhraseID
          },
          '+test' => 'Some content'
        }

        binding.pry
      ca = Card['Designer+MetricName+test']
      expect(ca.set_names).to include("Designer+MetricName+test+*metric type plus right")
    end
  end
end
