RSpec.describe Calculate::Calculator::InputItem do
  include_context "with company ids"

  def input_item mark, options={}
    described_class.new mark.card, 0, 1, options
  end

  def all_years value
    expected = (1990..2020).each_with_object({}) { |year, h| h[year] = value }
    expected[1977] = value
    expected
  end

  describe "#record_for" do
    let(:mark) { "Jedi+Victims by Employees" }

    def record_for company, year, options={}
      ii = input_item mark, options
      ii.search
      ii.record_for company, year
    end

    def record_value_hash *args
      record_for(*args).each_with_object({}) do |(year, record), hash|
        hash[year] = record.value
      end
    end

    context "without options" do
      example "no year specified" do
        expect(record_for(death_star, nil).values.first.value).to eq("0.31")
      end

      example "year specified" do
        expect(record_for(death_star, 1977).value).to eq("0.31")
      end
    end

    describe "year options" do
      example "metric with fixed year option" do
        records = record_for death_star, nil, year: "1977"
        expect(records.length).to eq(32)
        expect(records.values.map(&:value).uniq).to eq ["0.31"]
      end

      example "metric with relative year option" do
        expect(record_for(death_star, nil, year: "-1")[1978].value).to eq("0.31")
      end

      context "with disturbance" do
        let(:mark) { "Jedi+disturbances in the Force" }

        example "metric with relative year list" do
          expect(record_for(death_star, nil, year: "-23, 0, 1")[2000].value)
            .to eq %w[yes yes yes]
        end

        example "metric with fixed year list" do
          expect(record_for(death_star, nil, year: "1977, 2000").values.map(&:value).uniq)
            .to eq [%w[yes yes]]
        end

        # for monster inc, 2000 is yes, 1977 is no
        example "previous year" do
          record = record_for "Monster Inc".card_id, 2000, year: "previous"
          expect(record.value).to eq "no"
        end
      end

      context "with researched" do
        let(:mark) { "Joe User+researched number 1" }

        example "metric with relative year range" do
          expect(record_for(samsung, nil, year: "-1..0")[2015].value).to eq(%w[10 5])
        end

        example "metric with year range with fixed start and relative stop " do
          expect(record_value_hash(samsung, nil, year: "2014..0"))
            .to eq 2015 => %w[10 5], 2014 => ["10"]
        end

        example "metric with year range with relative start and fixed stop " do
          expect(record_value_hash(samsung, nil, year: "0..2015"))
            .to eq 2014 => %w[10 5], 2015 => ["5"]
        end

        example "metric with year fixed range" do
          expect(record_for(samsung, 2000, year: "2014..2015").value).to eq %w[10 5]
        end

        example "metric with latest year" do
          expect(record_for(samsung, 2000, year: "latest").value).to eq "5"
        end
      end
    end

    describe "company options" do
      let(:mark) { "Jedi+deadliness" }

      example "single company" do
        expect(record_value_hash(death_star, nil, company: "Death Star"))
          .to eq(1977 => "100")
      end

      example "company group" do
        expect(record_value_hash(samsung, nil, company: "Deadliest")[1977].sort)
          .to eq(%w[100 40 50])
      end

      example "metric with related company option" do
        expect(record_value_hash(death_star, nil, company: "Jedi+more evil"))
          .to eq(1977 => %w[40 50])
      end

      context "when subject company does not have record" do
        # there was previously an issue where records seemed to be working because
        # Death Star had an record for
        let(:mark) { "Joe User+RM" }

        example "inverse metric with related company option" do
          expect(record_value_hash(spectre, nil, company: "Jedi+less evil"))
            .to eq(1977 => %w[77])
        end
      end

      example "metric with company and year options" do
        expect(record_value_hash(death_star, nil, year: "-1", company: "Jedi+more evil"))
          .to eq(1978 => %w[40 50])
      end
    end
  end
end
