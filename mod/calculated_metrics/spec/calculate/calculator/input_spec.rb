require_relative "../../support/calculator_stub"
require "./spec/support/company_ids"

RSpec.describe Calculate::Calculator::Input do
  include_context "with calculator stub"
  include_context "with company ids"

  let :input do
    fc = parser_with_input @input, year: @year_options,
                                   company: @company_options,
                                   unknown: @unknown_options,
                                   not_researched: @not_researched_options
    described_class.new(fc, &:to_f)
  end

  def input_answers years, companies=nil
    [].tap do |yields|
      input.each years: years, companies: companies do |input_answers, company, year|
        input_values = input_answers.map { |a| a&.value }
        yields << [input_values, company, year]
      end
    end
  end

  example "single input" do
    @input = ["Jedi+deadliness"]
    expect(input_answers(1977, "Death Star")).to eq([[[100.0], death_star_id, 1977]])
  end

  example "two metrics" do
    @input = %w[Jedi+deadliness Joe_User+RM]
    expect(input_answers(1977)).to eq([[[100.0, 77.0], death_star_id, 1977]])
  end

  example "two metrics with :all values" do
    @input = %w[Joe_User+researched_number_1 Joe_User+researched_number_2]
    expect(input_answers(2015)).to eq([[[5.0, 2.0], samsung_id, 2015]])
  end

  example "two metrics with not researched options" do
    @input = %w[Joe_User+researched_number_1 Joe_User+researched_number_2]
    @not_researched_options = %w[false false]
    expect(input_answers(2015))
      .to eq([[[100.0, nil], apple_id, 2015],
              [[5.0, 2.0], samsung_id, 2015]])
  end

  context "with year option" do
    before do
      @input = ["Joe User+RM"]
    end

    it "relative range" do
      @year_options = ["-1..0"]
      expect(input_answers(2013, "Apple Inc"))
        .to eq([[[[12.0, 13.0]], apple_id, 2013]])
    end

    it "relative year" do
      @year_options = ["-1"]
      expect(input_answers(2014, "Apple Inc"))
        .to eq([[[13.0], apple_id, 2014]])
    end

    it "fixed start range" do
      @year_options = ["2010..0"]
      expect(input_answers(2013, "Apple Inc"))
        .to eq([[[[10.0, 11.0, 12.0, 13.0]], apple_id, 2013]])
    end
  end

  context "with company option" do
    example "related" do
      @input ||= ["Jedi+deadliness"]
      @company_options = ["Related[Jedi+more evil = yes]"]
      expect(input_answers(1977, "Death Star"))
        .to eq([[[[40.0, 50.0]], death_star_id, 1977]])
    end
  end

  describe "#each" do
    before do
      @input ||= ["Joe User+RM"]
    end

    it "handles array of Integers for years" do
      expect(input_answers([2013, 2014], "Apple Inc"))
        .to eq([[[13.0], apple_id, 2013], [[14.0], apple_id, 2014]])
    end

    it "handles array of Strings for years" do
      expect(input_answers(%w[2013 2014], "Apple Inc"))
        .to eq([[[13.0], apple_id, 2013], [[14.0], apple_id, 2014]])
    end

    it "handles array of Integers for companies" do
      @input = ["Jedi+deadliness"]
      expect(input_answers(1977, [death_star_id, samsung_id]))
        .to eq([[[100.0], death_star_id, 1977], [[:unknown], samsung_id, 1977]])
    end
  end
end
