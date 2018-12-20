require_relative "../../../support/calculator_stub"

RSpec.describe Formula::Calculator::Input do
  include_context "with calculator stub"

  let :input do
    fc = parser_with_input @input, @year_options, @company_options, @unknown_options,
                           @not_researched_options
    described_class.new(fc, &:to_f)
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
    @input = %w[Jedi+deadliness Joe_User+RM]
    expect { |b| input.each(year: 1977, &b) }
      .to yield_with_args([100.0, 77.0], death_star_id, 1977)
  end

  example "two metrics with :all values" do
    @input = %w[Joe_User+researched_number_1 Joe_User+researched_number_2]
    expect { |b| input.each(year: 2015, &b) }
      .to yield_with_args([5.0, 2.0], samsung_id, 2015)
  end

  example "two metrics with :any values" do
    @input = %w[Joe_User+researched_number_1 Joe_User+researched_number_2]
    @not_researched_options = ["false", "false"]
    expect { |b| input.each(year: 2015, &b) }
      .to yield_successive_args([[5.0, 2.0], samsung_id, 2015],
                                [[100.0, nil], apple_id, 2015])
  end

  example "yearly variable" do
    @input = ["half year", "Joe User+researched number 1"]
    expect { |b| input.each(year: 2015, &b) }
      .to yield_successive_args([[1007.5, 5.0], samsung_id, 2015],
                                [[1007.5, 100.0], apple_id, 2015])
  end

  context "with year option" do
    it "relative range" do
      @input = ["Joe User+RM"]
      @year_options = ["-1..0"]
      expect { |b| input.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[12.0, 13.0]], apple_id, 2013)
    end

    it "relative year" do
      @input = ["Joe User+RM"]
      @year_options = ["-1"]
      expect { |b| input.each(year: 2014, company: "Apple Inc", &b) }
        .to yield_with_args([13.0], apple_id, 2014)
    end

    it "fixed start range" do
      @input = ["Joe User+RM"]
      @year_options = ["2010..0"]
      expect { |b| input.each(year: 2013, company: "Apple Inc", &b) }
        .to yield_with_args([[10.0, 11.0, 12.0, 13.0]], apple_id, 2013)
    end
  end

  context "with company option" do
    example "related" do
      @input = ["Jedi+deadliness"]
      @company_options = ["Related[Jedi+more evil = yes]"]
      expect { |b| input.each(year: 1977, company: "Death Star", &b) }
        .to yield_with_args([[50.0, 40.0]], death_star_id, 1977)
    end
  end
end
