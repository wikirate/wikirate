RSpec.describe Calculate::Calculator::Input do
  include_context "with company ids"

  def input input_array
    described_class.new(input_array, &:to_f)
  end

  describe "#each" do
    def input_each metrics, years, companies=nil
      input_yields metrics do |input, yields|
        input.each years: years, companies: companies do |input_answers, company, year|
          input_values = input_answers.map { |a| a&.value }
          yields << [input_values, company, year]
        end
      end
    end

    def input_yields metrics
      input_array = Array.wrap(metrics).map { |m| m.is_a?(Hash) ? m : { metric: m } }
      [].tap do |yields|
        yield input(input_array), yields
      end
    end

    example "single input" do
      expect(input_each("Jedi+deadliness", 1977, "Death Star"))
        .to eq([[[100.0], death_star_id, 1977]])
    end

    example "two metrics" do
      expect(input_each(%w[Jedi+deadliness Joe_User+RM], 1977))
        .to eq([[[100.0, 77.0], death_star_id, 1977]])
    end

    example "two metrics with :all values" do
      expect(
        input_each(%w[Joe_User+researched_number_1 Joe_User+researched_number_2], 2015)
      ).to eq([[[5.0, 2.0], samsung_id, 2015]])
    end

    example "two metrics with not researched options" do
      yields = input_each(
        [{ metric: "Joe User+researched number 1", not_researched: "false" },
         { metric: "Joe User+researched number 2", not_researched: "false" }],
        2015
      )

      expect(yields.size).to eq(2)
      expect(yields).to include([[100.0, nil], apple_id, 2015])
      expect(yields).to include([[5.0, 2.0], samsung_id, 2015])
    end

    context "with year option" do
      def input_each_with_year year_option, year
        input_each [{ metric: "Joe User+RM", year: year_option }], year, "Apple Inc"
      end

      it "relative range" do
        expect(input_each_with_year("-1..0", 2013))
          .to eq([[[[12.0, 13.0]], apple_id, 2013]])
      end

      it "relative year" do
        expect(input_each_with_year("-1", 2014))
          .to eq([[[13.0], apple_id, 2014]])
      end

      it "fixed start range" do
        expect(input_each_with_year("2010..0", 2013))
          .to eq([[[[10.0, 11.0, 12.0, 13.0]], apple_id, 2013]])
      end
    end

    context "with company option" do
      example "related" do
        # @input ||= ["Jedi+deadliness"]
        # @company_options = []
        # input_answers(

        expect(
          input_each(
            [{ metric: "Jedi+deadliness", company: "Jedi+more evil" }],
            1977, "Death Star"
          )
        ).to eq([[[[40.0, 50.0]], death_star_id, 1977]])
      end
    end

    it "handles array of Integers for years" do
      expect(input_each("Joe User+RM", [2013, 2014], "Apple Inc"))
        .to eq([[[13.0], apple_id, 2013], [[14.0], apple_id, 2014]])
    end

    it "handles array of Strings for years" do
      expect(input_each("Joe User+RM", %w[2013 2014], "Apple Inc"))
        .to eq([[[13.0], apple_id, 2013], [[14.0], apple_id, 2014]])
    end

    it "handles array of Integers for companies" do
      expect(input_each("Jedi+deadliness", 1977, [death_star_id, samsung_id]))
        .to eq([[[100.0], death_star_id, 1977], [[:unknown], samsung_id, 1977]])
    end
  end

  describe "#answers_for" do
    def answers_for *args
      input(input_array).answers_for(*args)
    end

    context "with single metric" do
      let(:input_array) { [{ metric: "Jedi+Victims by Employees" }] }

      example "no year specified" do
        expect(answers_for(death_star, nil).first.first.value).to eq("0.31")
      end

      example "year specified" do
        expect(answers_for(death_star, 1977).first.first.value).to eq("0.31")
      end

      context "with relative year" do
        let(:input_array) { [{ metric: "Jedi+Disturbances in the Force", year: "-1" }] }

        example "year specified" do
          answers = answers_for death_star, 1993
          expect(answers.size).to eq(1)
          expect(answers.first.first.value).to eq("yes")
        end
      end
    end

    context "with two metrics" do
      let :input_array do
        [{ metric: "Jedi+Victims by Employees" }, { metric: "Jedi+deadliness" }]
      end

      example "no year specified" do
        expect(answers_for(death_star, nil).map(&:first).map(&:value))
          .to eq(["0.31", "100"])
      end

      example "year specified" do
        expect(answers_for(death_star, 1977).map(&:first).map(&:value))
          .to eq(["0.31", "100"])
      end
    end
  end

  describe "input_for" do
    def input_for *args
      input(input_array).input_for(*args)
    end

    context "with single metric" do
      let(:input_array) { [{ metric: "Jedi+Victims by Employees" }] }

      example "year specified" do
        expect(input_for(death_star, 1977)).to eq([0.31])
      end
    end

    context "with two metrics" do
      let :input_array do
        [{ metric: "Jedi+Victims by Employees" }, { metric: "Jedi+deadliness" }]
      end

      example "year specified" do
        expect(input_for(death_star, 1977)).to eq([0.31, 100])
      end
    end
  end
end
