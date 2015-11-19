# -*- encoding : utf-8 -*-

describe Card::Set::CalculationType::WikiRating do
  it 'works' do
    Card::Auth.as_bot do
      @card = Card.create! name: 'Jedi+evil rating', type_id: Card::MetricID,
                          subcards: {
                            '+*metric type' => "[[#{Card[:wiki_rating].name}]]",
                            '+formula' => '{{Jedi+deadliness}}*5/10'
                          }
    end
    expect(Card['Jedi+evil rating+Death Star+1977+value'].content).to eq('50')
  end

#  it 'updates vlu'

  describe 'valid_ruby_expression?' do
    subject do
      Card::Auth.as_bot do
        Card.create! name: 'Jedi+evil rating', type_id: Card::MetricID,
                     subcards: {
                      '+*metric type' => "[[#{Card[:wiki_rating].name}]]",
                     }
      end
    end
    it 'allows math operations' do
      expect(subject.valid_ruby_expression? '5 * 4 / 2 - 2.3 + 5').to be_truthy
    end

    it 'allows parens' do
      expect(subject.valid_ruby_expression? '5 * (4 / 2) - 2').to be_truthy
    end

    it 'allows index access to args' do
      expect(subject.valid_ruby_expression? '5 * args[1] + 5').to be_truthy
    end

    it 'denies letters' do
      expect(subject.valid_ruby_expression? '5 * 4*a / 2 - 2 + 5').to be_falsey
    end
  end
end