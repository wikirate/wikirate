require "./test/seed"

RSpec.describe Card::Set::TypePlusRight::Metric::AllMetricValues do
  let(:metric) { @metric || Card["Jedi+disturbances in the Force"] }
  let(:all_metric_values) { metric.fetch trait: :all_metric_values }
  let(:latest_answers) do
    ["Death_Star+2001", "Monster_Inc+2000", "Slate_Rock_and_Gravel_Company+2005",
     "SPECTRE+2000"]
  end
  let(:latest_answer_keys) do
    ::Set.new(latest_answers.map { |n| n.to_name.left_name.key })
  end
  let(:all_companies) do
    Card.search type_id: Card::WikirateCompanyID, return: :name
  end
  let(:missing_companies) do
    all_companies.reject do |name|
      latest_answer_keys.include? name.to_name.key
    end
  end

  def missing_answers year=Time.now.year
    with_year missing_companies, year
  end

  def with_year list, year=Time.now.year
    Array(list).map { |name| "#{name}+#{year}" }
  end

  # return company+year
  def answers list
    list.map do |c|
      c.name.parts[2..3].join "+"
    end
  end

  describe "#item_cards" do
    subject(:answer_list) do
      answers all_metric_values.item_cards
    end

    it "returns the latest values in default order" do
      expect(answer_list).to eq(latest_answers)
    end

    def filter_by args
      allow(all_metric_values).to receive(:filter_hash) { args }
      answers all_metric_values.item_cards
    end

    context "with single filter condition" do
      context "with keyword" do
        it "finds exact match" do
          expect(filter_by(name: "Death")).to eq ["Death_Star+2001"]
        end

        it "finds partial match" do
          expect(filter_by(name: "at"))
            .to eq %w[Death_Star+2001 Slate_Rock_and_Gravel_Company+2005]
        end

        it "ignores case" do
          expect(filter_by(name: "death"))
            .to eq ["Death_Star+2001"]
        end
      end

      it "finds exact match by year" do
        expect(filter_by(year: "2000"))
          .to eq with_year(%w[Death_Star Monster_Inc SPECTRE], 2000)
      end

      it "finds exact match by project" do
        expect(filter_by(project: "Evil Project"))
          .to eq %w[Death_Star+2001 SPECTRE+2000]
      end

      it "finds exact match by industry" do
        expect(filter_by(industry: "Technology Hardware"))
          .to eq %w[Death_Star+2001 SPECTRE+2000]
      end

      context "with value" do
        let(:all_answers) do
          latest_answers + missing_answers
        end

        it "finds missing values" do
          expect(filter_by(metric_value: :none))
            .to contain_exactly(*missing_answers)
        end

        it "finds all values" do
          filtered = filter_by(metric_value: :all)
          expect(filtered)
            .to include(*all_answers)
        end

        context "filter by update date" do
          before do
            Timecop.freeze(SharedData::HAPPY_BIRTHDAY)
          end
          after do
            Timecop.return
          end
          it "finds today's edits" do
            expect(filter_by(metric_value: :today))
              .to eq %w[Death_Star+1990]
          end

          it "finds this week's edits" do
            expect(filter_by(metric_value: :week))
              .to eq %w[Death_Star+1990 Death_Star+1991]
          end

          it "finds this months's edits" do
            # wrong only one company
            expect(filter_by(metric_value: :month))
              .to eq %w[Death_Star+1990 Death_Star+1991 Death_Star+1992]
          end
        end
      end
      context "invalid filter key" do
        it "doesn't matter" do
          expect(filter_by(not_a_filter: "Death"))
            .to eq latest_answers
        end
      end
    end

    context "with multiple filter conditions" do
      context "filter for missing values and ..." do
        it "... year" do
          missing2000 = missing_answers(2000)
          missing2000 << "Slate Rock and Gravel Company+2000"
          expect(filter_by(metric_value: :none, year: "2000").sort)
            .to eq(missing2000.sort)
        end

        it "... keyword" do
          expect(filter_by(metric_value: :none, name: "Inc").sort)
            .to eq(with_year(["AT&T Inc.", "Amazon.com, Inc.",
                              "Apple Inc.", "Google Inc."]))
        end

        it "... project" do
          expect(filter_by(metric_value: :none, project: "Evil Project").sort)
            .to eq(with_year(["Los Pollos Hermanos"]))
        end

        it "... industry" do
          expect(filter_by(metric_value: :none,
                           industry: "Technology Hardware"))
            .to eq []
        end

        it "... industry and year" do
          expect(filter_by(metric_value: :none,
                           industry: "Technology Hardware",
                           year: "2001"))
            .to eq ["SPECTRE+2001"]
        end
      end

      context "filter for all values and ..." do
        it "... project" do
          expect(filter_by(metric_value: :all, project: "Evil Project"))
            .to contain_exactly("Death_Star+2001", "SPECTRE+2000",
                                *with_year("Los Pollos Hermanos"))
        end

        it "... year" do
          i = all_companies.index("Death Star")
          all_companies[i] = "Death_Star"
          expect(filter_by(metric_value: :all, year: "2001"))
            .to contain_exactly(*with_year(all_companies, 2001))
        end

        it "... industry and year" do
          expect(filter_by(metric_value: :all,
                           industry: "Technology Hardware",
                           year: "2001"))
            .to contain_exactly(*with_year(%w[SPECTRE Death_Star], 2001))
        end
      end

      it "project and industry" do
        expect(filter_by(project: "Evil Project",
                         industry: "Technology Hardware"))
          .to eq(["Death_Star+2001", "SPECTRE+2000"])
      end
      it "year and industry" do
        expect(filter_by(year: "1977",
                         industry: "Technology Hardware"))
          .to eq(with_year("Death_Star", 1977))
      end
      it "all in" do
        Timecop.freeze(SharedData::HAPPY_BIRTHDAY) do
          expect(filter_by(year: "1990",
                           industry: "Technology Hardware",
                           project: "Evil Project",
                           metric_value: :today,
                           name: "star"))
            .to eq(with_year("Death_Star", 1990))
        end
      end
    end

    context "with sort conditions" do
      def sort_answers_by key, order="asc"
        allow(all_metric_values).to receive(:sort_by) { key }
        allow(all_metric_values).to receive(:sort_order) { order }
        answers all_metric_values.item_cards
      end

      it "sorts by company name (asc)" do
        expect(sort_answers_by(:company_name)).to eq(
          [
            "Death_Star+2001",
            "Monster_Inc+2000",
            "Slate_Rock_and_Gravel_Company+2005",
            "SPECTRE+2000"
          ]
        )
      end

      it "sorts by company name (desc)" do
        expect(sort_answers_by(:company_name, "desc")).to eq(
          [
            "Death_Star+2001",
            "Monster_Inc+2000",
            "Slate_Rock_and_Gravel_Company+2005",
            "SPECTRE+2000"
          ].reverse
        )
      end

      it "sorts categories by value" do
        res = sort_answers_by(:value)
        yes_index = res.index "Death_Star+2001"
        no_index = res.index "Slate_Rock_and_Gravel_Company+2005"
        expect(no_index).to be < yes_index
      end

      it "sorts numberics by value" do
        @metric = Card["Jedi+deadliness"]
        expect(sort_answers_by(:value)).to eq(
          %w[Samsung+1977
             Slate_Rock_and_Gravel_Company+2005
             Los_Pollos_Hermanos+1977
             SPECTRE+1977
             Death_Star+1977]
        )
      end

      it "sorts floats by value" do
        @metric = Card["Jedi+Victims by Employees"]
        expect(sort_answers_by(:value)).to eq(
          with_year(%w[Samsung
                       Slate_Rock_and_Gravel_Company
                       Monster_Inc
                       Los_Pollos_Hermanos
                       Death_Star
                       SPECTRE],
                    1977)
        )
      end
    end
  end

  describe "#count" do
    it "returns correct count" do
      expect(all_metric_values.count).to eq(4)
    end
  end

  describe "view" do
    let(:metric) { "Jedi+disturbances_in_the_Force" }
    let(:metric_answer) { "Jedi+disturbances_in_the_Force+Death_Star+2001" }

    describe ":table" do
      context "when metric researched" do
        subject do
          Card.fetch([metric, :all_metric_values]).format(:html)._render_table
        end

        it "has a bootstrap table" do
          is_expected.to have_tag "table" do
            details_url = "/#{metric_answer}?view=company_details_sidebar"
            with_tag :tr, with: { "data-details-url" => details_url }
          end
        end
      end

      context "when metric researched" do
        subject do
          Card.fetch(["Jedi+friendliness", :all_metric_values])
              .format(:html)._render_table
        end

        example "formula metric" do
          metric_answer = "Jedi+friendliness+Death_Star+1977"
          is_expected.to have_tag "table" do
            details_url = "/#{metric_answer}?view=company_details_sidebar"
            with_tag :tr, with: { "data-details-url" => details_url }
          end
        end
      end
    end

    describe ":core" do
      subject do
        Card.fetch([metric, :all_metric_values]).format(:html)._render_core
      end

      it "has filter widget" do
        is_expected.to have_tag ".card" do
          with_tag "._filter-widget"
        end
      end
      it "has chart" do
        is_expected.to have_tag ".row" do
          url = "/Jedi+disturbances_in_the_Force+all_metric_values.json?view=vega"
          with_tag ".vis", with: { "data-url": url }
        end
      end
      it "has counts" do
        is_expected.to have_tag "table.filtered-answer-counts" do
          with_tag "span.known.badge", "4"
        end
      end
      it "has table" do
        is_expected.to have_tag "table" do
          with_text(/Death Star\s*yes\s*yes,no\s*2001/)
        end
      end
    end
  end
end
