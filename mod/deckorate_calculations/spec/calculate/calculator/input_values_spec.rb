RSpec.describe Calculate::Calculator::Input do
  include_context "with company ids"

  def input input_array
    described_class.new input_array
  end

  def input_list input_array
    i = input input_array
    i.send :search_values_for
    i.input_list
  end

  def answer_value_hash item, *args
    item.answer_for(*args).each_with_object({}) do |(year, answer), hash|
      hash[year] = answer.value
    end
  end

  describe "#answers_for" do
    def answers_for *args
      input(input_array).answers_for *args
    end

    context "single metric" do
      let(:input_array) { [{ metric: "Jedi+Victims by Employees" }] }

      example "no year specified" do
        expect(answers_for(death_star, nil).first.value).to eq("0.31")
      end

      example "year specified" do
        expect(answers_for(death_star, 1977).first.value).to eq("0.31")
      end
    end

    context "two metrics" do
      let :input_array do
        [{ metric: "Jedi+Victims by Employees" }, { metric: "Jedi+deadliness" }]
      end

      example "no year specified" do
        expect(answers_for(death_star, nil).map(&:value)).to eq(["0.31", "100"])
      end

      example "year specified" do
        expect(answers_for(death_star, 1977).map(&:value)).to eq(["0.31", "100"])
      end
    end
  end

  describe "input_for" do
    def input_for *args
      input(input_array).input_for *args
    end

    context "single metric" do
      let(:input_array) { [{ metric: "Jedi+Victims by Employees" }] }

      example "year specified" do
        expect(input_for(death_star, 1977)).to eq(["0.31"])
      end
    end

    context "two metrics" do
      let :input_array do
        [{ metric: "Jedi+Victims by Employees" }, { metric: "Jedi+deadliness" }]
      end

      example "year specified" do
        expect(input_for(death_star, 1977)).to eq(["0.31", "100"])
      end
    end
  end

  def all_years value
    expected = (1990..2020).each_with_object({}) { |year, h| h[year] = value }
    expected[1977] = value
    expected
  end

  describe "year options" do
    example "metric with fixed year option" do
      ii, = input_items "2*{{Jedi+Victims by Employees|year:1977}}"

      expect(answer_value_hash(ii, death_star, nil))
        .to eq all_years("0.31")
    end

    example "metric with relative year option" do
      ii, = input_items "2*{{Jedi+Victims by Employees|year:-1}}"
      expect(answer_value_hash(ii, death_star, nil))
        .to eq 1978 => "0.31"
    end

    example "metric with relative year list" do
      ii, = input_items "{{Jedi+disturbances in the Force|year: -23, 0, 1}}"
      expect(answer_value_hash(ii, death_star, nil))
        .to eq 2000 => %w[yes yes yes]
    end

    example "metric with fixed year list" do
      ii, = input_items "{{Jedi+disturbances in the Force|year: 1977, 2000}}"
      expect(answer_value_hash(ii, death_star, nil))
        .to eq all_years(%w[yes yes])
    end

    example "metric with relative year range" do
      ii, = input_items "{{Joe User+researched number 1|year:-1..0}}"
      expect(answer_value_hash(ii, samsung, nil))
        .to eq 2015 => %w[10 5]
    end

    example "metric with year range with fixed start and relative stop " do
      ii, = input_items "{{Joe User+researched number 1|year:2014..0}}"
      expect(answer_value_hash(ii, samsung, nil))
        .to eq 2015 => %w[10 5], 2014 => ["10"]
    end

    example "metric with year range with relative start and fixed stop " do
      ii, = input_items "{{Joe User+researched number 1|year:0..2015}}"
      expect(answer_value_hash(ii, samsung, nil))
        .to eq 2014 => %w[10 5], 2015 => ["5"]
    end

    example "metric with year fixed range" do
      ii, = input_items "{{Joe User+researched number 1|year:2014..2015}}"
      expect(ii.answer_for(samsung, 2000).value)
        .to eq %w[10 5]
    end

    example "metric with latest year" do
      ii, = input_items "{{Joe User+researched number 1|year:latest}}"
      expect(ii.answer_for(samsung, 2000).value)
        .to eq "5"
    end
  end

  describe "company options" do
    example "metric with related company option" do
      ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil=yes]}}"
      expect(answer_value_hash(ii, death_star, nil))
        .to eq(1977 => %w[40 50])
    end

    example "metric with related company options with 2 conditions" do
      ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil = yes && "\
                      "Commons+Supplied by = Tier 1 Supplier]}}"
      expect(answer_value_hash(ii, spectre, nil))
        .to eq(1977 => %w[40])
    end

    example "metric with fixed single company option" do
      ii, ii2 = input_items "{{Jedi+deadliness}} / {{Jedi+deadliness|company:Death Star}}"
      aggregate_failures do
        expect(answer_value_hash(ii, death_star, nil)).to eq(1977 => "100")
        expect(answer_value_hash(ii2, death_star, nil)).to eq(1977 => "100")
      end
    end

    example "metric with fixed list company option" do
      ii, ii2 = input_items(
        "{{Jedi+deadliness}} / {{Jedi+deadliness|company:Death Star, SPECTRE}}"
      )
      aggregate_failures do
        expect(answer_value_hash(ii, samsung, nil)).to eq(1977 => "Unknown")
        expect(answer_value_hash(ii2, samsung, nil)).to eq(1977 => %w[100 50])
      end
    end
  end

  example "metric with company and year options" do
    ii, = input_items "{{Jedi+deadliness|company:Related[Jedi+more evil=yes]; year: -1}}"
    expect(answer_value_hash(ii, death_star, nil))
      .to eq(1978 => %w[40 50])
  end
end
