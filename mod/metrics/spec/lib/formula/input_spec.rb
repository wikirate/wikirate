describe Formula::Calculator::Input do
  subject do
    input_cards = @input.map { |i| Card.fetch i }
    described_class.new(input_cards, @year_options, &:to_f)
  end

  it "single input" do
    @input = ["Jedi+deadliness"]
    expect { |b| subject.each(year: 1977, company: "Death Star", &b) }
      .to yield_with_args([100.0], "death_star", 1977)
  end

  it "two metrics" do
    @input = %w[Jedi+deadliness Joe_User+researched]
    expect { |b| subject.each(year: 1977, &b) }
      .to yield_with_args([100.0, 77.0], "death_star", 1977)
  end

  context "with year references" do
    it "relative range" do
      @input = ["Joe User+researched"]
      @year_options = ["-1..0"]
      expect { |b| subject.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[12.0, 13.0]], "apple_inc", 2013)
    end

    it "relative range" do
      @input = ["Joe User+researched"]
      @year_options = ["-1..0"]
      expect { |b| subject.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[12.0, 13.0]], "apple_inc", 2013)
    end

    it "fixed start range" do
      @input = ["Joe User+researched"]
      @year_options = ["2010..0"]
      expect { |b| subject.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[10.0, 11.0, 12.0, 13.0]], "apple_inc", 2013)
    end
  end
end
