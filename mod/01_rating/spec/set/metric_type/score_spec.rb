# -*- encoding : utf-8 -*-

# the metric in the test database:
# Card::Metric.create name: 'Jedi+deadliness+Joe User',
#                     type: :score,
#                     formula: '{{Jedi+deadliness}}/10'
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
      Card::Metric.create(
        name: 'Force score',
        type: :score,
        formula: '{{Jedi+deadliness}}/10 - 5'
      )
    end
    expect(Card['force score+Death Star+1977']).to be_truthy
    expect(Card['force score+Death Star+1977+value'].content).to eq '5'
  end

  it 'calculate more complicated scores'  do
    Card::Auth.as_bot do
      Card::Metric.create(
        name: 'Force score',
        type: :score,
        formula: '{{Jedi+deadliness}}/10 - 5 + ' \
                 'Boole[{{Jedi+disturbances in the Force}} == "yes"]'
      )
    end
    expect(Card['force score+Death Star+1977+value'].content).to eq '6'
  end

  context 'if original value changed' do
    before do
      Card['Jedi+deadliness+Death Star+1977+value'].update_attributes!(
        content: 40
      )
    end
    it 'updates scored valued' do
      expect(Card['Jedi+deadliness+Joe User+Death Star+1977+value'].content)
        .to eq 20
    end

    it 'updates dependent ratings' do
      expect(Card['Jedi+darkness rating+Death Star+1977+value'].content)
        .to eq 9
    end
  end
end
