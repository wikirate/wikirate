# encoding: UTF-8

describe Card::Set::TypePlusRight::Metric::Formula do
  describe '#ruby_formula?' do
    subject do
      Card::Auth.as_bot do
        Card.create! name: 'Jedi+evil rating', type_id: Card::MetricID,
                     subcards: {
                       '+*metric type' => "[[#{Card[:wiki_rating].name}]]",
                     }
      end
    end
    it 'allows math operations' do
      expect(subject.ruby_formula? '5 * 4 / 2 - 2.3 + 5').to be_truthy
    end

    it 'allows parens' do
      expect(subject.ruby_formula? '5 * (4 / 2) - 2').to be_truthy
    end

    it 'allows index access to args' do
      expect(subject.ruby_formula? '5 * args[1] + 5').to be_truthy
    end

    it 'denies letters' do
      expect(subject.ruby_formula? '5 * 4*a / 2 - 2 + 5').to be_falsey
    end
  end
end
