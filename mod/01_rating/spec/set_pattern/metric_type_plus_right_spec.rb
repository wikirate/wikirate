# encoding: UTF-8

describe Card::MetricTypePlusRightSet do
  it 'works' do
    Card::Auth.as_bot do
      Card::Metric.create! name: 'Designer+MetricName',
                           type: :wiki_rating,
                           '+test' => 'Some content'


      ca = Card['Designer+MetricName+test']
      expect(ca.set_names)
        .to include('Designer+MetricName+test+*metric type plus right')
    end
  end
end
