require "./spec/support/company_ids"

RSpec.describe Formula::Calculator::InputValues do
  include_context "company ids"

  describe "result space" do
    def input_values formula
      f_card = Card["Jedi+friendliness+formula"]
      f_card.content = formula
      described_class.new(f_card.parser)
    end

    def result_cache formula
      iv = input_values(formula)
      iv.send(:full_search)
      iv.result_cache
    end

    def expect_result_space rc, hash
      hash.transform_values!(&:to_set)
      expect(rc).to eq hash
    end

    example "single metric" do
      rc = result_cache "{{Joe User+researched number 2}}"
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung]
    end

    example "two metrics" do
      rc = result_cache "{{Joe User+researched number 1}} + {{Joe User+RM}}"
      expect_result_space rc, 1977 => [death_star], 2015 => [apple], 2002 => [apple]
    end

    example "with not_researched option" do
      rc = result_cache "{{Joe User+researched number 1}} +"\
                               " {{Joe User+researched number 2| not_researched: 5}}"
      expect_result_space rc, 2014 => [samsung, sony], 2015 => [samsung, apple],
                              1977 => [death_star], 2002 => [apple]
    end

    example "without mandatory input items" do
      rc = result_cache "{{Joe User+researched number 1| not_researched: 0}} +"\
                               "{{Jedi+deadliness| not_researched: 5}}"
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end

    example "without mandatory input items and unknown option" do
      rc = result_cache "{{Joe User+researched number 1|"\
                               "not_researched: 0}} +"\
                               "{{Jedi+deadliness| not_researched: 5; unknown: 0}}"
      expect_result_space rc,
                          2014 => [samsung, sony], 2015 => [samsung, apple],
                          1977 => [death_star, spectre, los_pollos, slate_rock, samsung],
                          2003 => [slate_rock], 2004 => [slate_rock],
                          2005 => [slate_rock], 2002 => [apple]
    end
  end

  def input_values formula
    f_card = Card["Jedi+friendliness+formula"]
    f_card.content = formula
    described_class.new(f_card.parser)
  end

  def input_items formula
    iv = input_values formula
    iv.send(:full_search)
    iv.instance_variable_get("@input_list")
  end

  def yearly_values
    [2004, 2013, 2014, 2015].each_with_object({}) do |y, h|
      h[y] = Card["A"].format
                      .number_with_precision(y / 2.0, precision: 5,
                                                      strip_insignificant_zeros: true)
                      .to_s
    end
  end

  example "single metric" do
    ii, = input_items "2*{{Jedi+Victims by Employees}}"
    aggregate_failures do
      expect(ii.value_for(death_star, nil)).to eq(1977 => "0.31")
      expect(ii.value_for(death_star, 1977)).to eq("0.31")
    end
  end

  example "two metrics" do
    ii, ii2 = input_items "{{Jedi+Victims by Employees}} + {{Jedi+deadliness}}"
    aggregate_failures do
      expect(ii.value_for(death_star, nil)).to eq(1977 => "0.31")
      expect(ii2.value_for(death_star, nil)).to eq(1977 => "100")
    end
  end

  example "yearly variable" do
    ii, = input_items "{{half year}}"
    expect(ii.value_for(death_star, nil)).to eq yearly_values
  end

  def all_years value
    expected = (1990..2020).each_with_object({}) { |year, h| h[year] = value }
    expected[1977] = value
    expected
  end

  describe "year options" do
    example "metric with fixed year option" do
      ii, = input_items "2*{{Jedi+Victims by Employees|year:1977}}"

      expect(ii.value_for(death_star, nil))
        .to eq all_years("0.31")
    end

    example "metric with relative year option" do
      ii, = input_items "2*{{Jedi+Victims by Employees|year:-1}}"
      expect(ii.value_for(death_star, nil))
        .to eq 1978 => "0.31"
    end

    example "metric with relative year list" do
      ii, = input_items "{{Jedi+disturbances in the Force|year: -23, 0, 1}}"
      expect(ii.value_for(death_star, nil))
        .to eq 2000 => %w[yes yes yes]
    end

    example "metric with fixed year list" do
      ii, = input_items "{{Jedi+disturbances in the Force|year: 1977, 2000}}"
      expect(ii.value_for(death_star, nil))
        .to eq all_years(%w[yes yes])
    end

    example "metric with relative year range" do
      ii, = input_items "{{Joe User+researched number 1|year:-1..0}}"
      expect(ii.value_for(samsung, nil))
        .to eq 2015 => %w[10 5]
    end

    example "metric with year range with fixed start and relative stop " do
      ii, = input_items "{{Joe User+researched number 1|year:2014..0}}"
      expect(ii.value_for(samsung, nil))
        .to eq 2015 => %w[10 5], 2014 => ["10"]
    end

    example "metric with year range with relative start and fixed stop " do
      ii, = input_items "{{Joe User+researched number 1|year:0..2015}}"
      expect(ii.value_for(samsung, nil))
        .to eq 2014 => %w[10 5], 2015 => ["5"]
    end

    example "metric with year fixed range" do
      ii, = input_items "{{Joe User+researched number 1|year:2014..2015}}"
      expect(ii.value_for(samsung, 2000))
        .to eq %w[10 5]
    end

    example "yearly variable with relative year option" do
      ii, = input_items "{{half year|year: -1}}"
      expect(ii.value_for(death_star, 2005)).to eq "1002"
    end

    example "yearly variable with relative year range" do
      ii, = input_items "{{half year|year: 2013..0}}"
      expect(ii.value_for(death_star, nil))
        .to eq 2013 => ["1006.5"], 2014 => %w[1006.5 1007], 2015 => %w[1006.5 1007 1007.5]
    end
  end

  describe "company options" do
    example "metric with related company option" do
      ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}"
      expect(ii.value_for(death_star, nil))
        .to eq(1977 => %w[50 40])
    end

    example "metric with related company options with 2 conditions" do
      ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil = yes && "\
                      "Commons+Supplied by = Tier 1 Supplier]}}"
      expect(ii.value_for(spectre, nil))
        .to eq(1977 => %w[40])
    end

    example "metric with fixed single company option" do
      ii, = input_items "{{Jedi+deadliness|company:Death Star}}"
      expect(ii.value_for(death_star, nil))
        .to eq(1977 => "100")
    end

    example "metric with fixed list company option" do
      ii, = input_items "{{Jedi+deadliness|company:Death Star, SPECTRE}}"
      expect(ii.value_for(samsung, nil))
        .to eq(1977 => %w[100 50])
    end

    example "yearly variable with company list" do
      ii, = input_items "{{half year|company: Death Star, SPECTRE}}"
      expect(ii.value_for(death_star, 2014))
        .to eq %w[1007 1007]
    end

    example "yearly variable with related company options", as_bot: true do
      Card.create!(name: "half year+1977", type_id: Card::YearlyAnswerID,
                   "+value" => { type_id: Card::YearlyValueID, content: "988.6" })
      ii, = input_items "{{half year|company:Related[Jedi+more evil = yes]}}"
      aggregate_failures do
        expect(ii.value_for(spectre, 1977)).to eq %w[988.6]
        expect(ii.value_for(death_star, 1977)).to eq %w[988.6 988.6]
      end
    end
  end

  example "metric with company and year options" do
    ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil=yes]; year: -1}}"
    expect(ii.value_for(death_star, nil))
      .to eq(1978 => %w[50 40])
  end
end
