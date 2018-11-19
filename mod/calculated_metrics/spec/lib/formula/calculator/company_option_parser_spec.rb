RSpec.describe Formula::Calculator::Input::CompanyOptionParser do
  let :input do
    @requirement ||= :all
    input_cards = @input.map { |i| Card.fetch i }
    described_class.new(input_cards, @requirement, @year_options, &:to_f)
  end

  let(:death_star_id) { Card.fetch_id "Death Star" }
  let(:apple_id) { Card.fetch_id "Apple Inc" }
  let(:samsung_id) { Card.fetch_id "Samsung" }


end
