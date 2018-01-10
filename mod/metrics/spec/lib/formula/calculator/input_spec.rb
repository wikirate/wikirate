RSpec.describe Formula::Calculator::Input do
  let :input do
    input_cards = @input.map { |i| Card.fetch i }
    described_class.new(input_cards, @year_options, &:to_f)
  end

  let(:death_star_id) { Card.fetch_id "Death Star" }
  let(:apple_id) { Card.fetch_id "Apple Inc" }
  let(:samsung_id) { Card.fetch_id "Samsung" }

  example "single input" do
    @input = ["Jedi+deadliness"]
    expect { |b| input.each(year: 1977, company: "Death Star", &b) }
      .to yield_with_args([100.0], death_star_id, 1977)
  end

  example "two metrics" do
    @input = %w[Jedi+deadliness Joe_User+researched]
    expect { |b| input.each(year: 1977, &b) }
      .to yield_with_args([100.0, 77.0], death_star_id, 1977)
  end

  example "yearly variable" do
    @input = ["half year", "Joe User+researched number 1"]
    expect { |b| input.each(year: 2015, &b) }
      .to yield_successive_args([[1007.5, 5.0], samsung_id, 2015],
                                [[1007.5, 100.0], apple_id, 2015])
  end

  context "with year references" do
    it "relative range" do
      @input = ["Joe User+researched"]
      @year_options = ["-1..0"]
      expect { |b| input.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[12.0, 13.0]], apple_id, 2013)
    end

    it "relative year" do
      @input = ["Joe User+researched"]
      @year_options = ["-1"]
      expect { |b| input.each(year: 2014, company: "Apple Inc", &b) }
        .to yield_with_args([13.0], apple_id, 2014)
    end

    it "fixed start range" do
      @input = ["Joe User+researched"]
      @year_options = ["2010..0"]
      expect { |b| input.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[10.0, 11.0, 12.0, 13.0]], apple_id, 2013)
    end
  end
end
